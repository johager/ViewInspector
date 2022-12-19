import ComposableArchitecture
import Foundation
import NMContentViews
import SwiftUI

// MARK: - ViewType.WithStateStore

extension ViewType {
    public struct WithStateStore: KnownViewType {
        public static var typePrefix = "WithStateStore"
        public static var namespacedPrefixes: [String] {
            ["NMContentViews", "NMContentViews.WithStateStore"]
        }
    }
}

// MARK: - WithStateStore + ViewWithBodyAsContent

extension WithStateStore: ViewWithBodyAsContent { }

// MARK: - ViewType.WithViewStore + SingleViewContent

extension ViewType.WithStateStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.WithViewStore + MultipleViewContent

extension ViewType.WithStateStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        
        guard let viewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.WithStateStore.typePrefix) }
        
        return try Inspector.viewsInContainer(view: viewWithBodyAsContent.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func withStateStore(
        _ index: Int) throws -> InspectableView<ViewType.WithStateStore>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyAsContent = childWrapper.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.WithStateStore.typePrefix) }

        let content = Content(viewWithBodyAsContent.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
