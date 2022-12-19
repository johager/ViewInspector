import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - ViewType.WithViewStore

extension ViewType {
    public struct WithViewStore: KnownViewType {
        public static var typePrefix = "WithViewStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture", "ComposableArchitecture.WithViewStore"]
        }
    }
}

// MARK: - WithViewStore + ViewWithBodyAsContent

extension WithViewStore: ViewWithBodyAsContent { }

// MARK: - ViewType.WithViewStore + SingleViewContent

extension ViewType.WithViewStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.WithViewStore + MultipleViewContent

extension ViewType.WithViewStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        
        guard let viewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.WithViewStore.typePrefix) }
        
        return try Inspector.viewsInContainer(view: viewWithBodyAsContent.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func withViewStore(
        _ index: Int) throws -> InspectableView<ViewType.WithViewStore>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyAsContent = childWrapper.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.WithViewStore.typePrefix) }

        let content = Content(viewWithBodyAsContent.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
