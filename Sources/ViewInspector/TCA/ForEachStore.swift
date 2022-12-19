import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - ViewType.ForEachStore

extension ViewType {
    public struct ForEachStore: KnownViewType {
        public static var typePrefix = "ForEachStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture", "ComposableArchitecture.ForEachStore"]
        }
    }
}

// MARK: - ForEachStore + ViewWithBodyAsContent

extension ForEachStore: ViewWithBodyAsContent { }

// MARK: - ViewType.ForEachStore + SingleViewContent

extension ViewType.ForEachStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.ForEachStore + MultipleViewContent

extension ViewType.ForEachStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        
        guard let viewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.ForEachStore.typePrefix) }
        
        return try Inspector.viewsInContainer(view: viewWithBodyAsContent.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func forEachStore(
        _ index: Int) throws -> InspectableView<ViewType.ForEachStore>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyAsContent = childWrapper.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.ForEachStore.typePrefix) }

        let content = Content(viewWithBodyAsContent.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
