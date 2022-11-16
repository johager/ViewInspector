import ComposableArchitecture
import Foundation
import NMContentViews
import SwiftUI

// MARK: - LazyView + ViewWithBodyFromClosure

extension LazyView: ViewWithBodyFromClosure { }

// MARK: - ViewType.LazyView

extension ViewType {
    public struct LazyView: KnownViewType {
        public static var typePrefix = "LazyView"
        public static var namespacedPrefixes: [String] {
            ["NMContentViews", "NMContentViews.LazyView"]
        }
    }
}

// MARK: - ViewType.WithViewStore + SingleViewContent

extension ViewType.LazyView: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
//        print("=== WithViewStore.\(#function) ===")
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.WithViewStore + MultipleViewContent

extension ViewType.LazyView: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let typePrefix = ViewType.LazyView.typePrefix
//        print("=== \(file).\(#function) ===")
        
//        print(">-- --- --- --- -->")
//        print("--- \(typePrefix).\(#function) - content: \(content)")
//        print(">-- --- --- --- -->")
        
        guard let viewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: typePrefix) }
        
//        print(">-- --- --- --- -->")
//        print("--- \(typePrefix).\(#function) - viewWithBodyFromClosure.body: \(viewWithBodyFromClosure.body)")
//        print(">-- --- --- --- -->")
        
        return try Inspector.viewsInContainer(view: viewWithBodyFromClosure.body, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

extension InspectableView where View: SingleViewContent {
    public func lazyView() throws -> InspectableView<ViewType.LazyView> {
//        print("=== LazyView.\(#function) ===")
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func lazyView(
        _ index: Int) throws -> InspectableView<ViewType.LazyView>
    {
        let file = ViewType.LazyView.typePrefix
//        print("=== \(#file).\(#function) - index: \(index) ===")

        let childWrapper = try child(at: index)
//        print("--- \(file).\(#function) - index: \(index), childWrapper: \(childWrapper)")

//        print("--- \(file).\(#function) - index: \(index), childWrapper.view: \(childWrapper.view)")

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: file) }

//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - viewWithBodyFromClosure: \(viewWithBodyFromClosure)")
//        print(">-- --- --- --- -->")

        let content = Content(viewWithBodyFromClosure.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
