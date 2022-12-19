import ComposableArchitecture
import Foundation
import NMContentViews
import SwiftUI

// MARK: - ViewType.LazyView

extension ViewType {
    public struct LazyView: KnownViewType {
        public static var typePrefix = "LazyView"
        public static var namespacedPrefixes: [String] {
            ["NMContentViews", "NMContentViews.LazyView"]
        }
    }
}

// MARK: - LazyView + ViewWithBodyAsContent

extension LazyView: ViewWithBodyAsContent { }

// MARK: - ViewType.LazyView + SingleViewContent

extension ViewType.LazyView: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.LazyView + MultipleViewContent

extension ViewType.LazyView: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {

        guard let viewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.LazyView.typePrefix) }
        
        return try Inspector.viewsInContainer(view: viewWithBodyAsContent.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func lazyView(
        _ index: Int) throws -> InspectableView<ViewType.LazyView>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyAsContent = childWrapper.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.LazyView.typePrefix) }

        let content = Content(viewWithBodyAsContent.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
