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

// MARK: - LazyView + ViewWithBodyFromClosure

extension LazyView: ViewWithBodyFromClosure { }

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

        guard let viewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: ViewType.LazyView.typePrefix) }
        
        return try Inspector.viewsInContainer(view: viewWithBodyFromClosure.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func lazyView(
        _ index: Int) throws -> InspectableView<ViewType.LazyView>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: ViewType.LazyView.typePrefix) }

        let content = Content(viewWithBodyFromClosure.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
