import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - WithViewStore + ViewWithBodyFromClosure

extension WithViewStore: ViewWithBodyFromClosure { }

// MARK: - ViewType.WithViewStore

extension ViewType {
    public struct WithViewStore: KnownViewType {
        public static var typePrefix = "WithViewStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture", "ComposableArchitecture.WithViewStore"]
        }
    }
}

// MARK: - ViewType.WithViewStore + SingleViewContent

extension ViewType.WithViewStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
//        print("=== WithViewStore.\(#function) ===")
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.WithViewStore + MultipleViewContent

extension ViewType.WithViewStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let typePrefix = ViewType.WithViewStore.typePrefix
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
    public func withViewStore() throws -> InspectableView<ViewType.WithViewStore> {
//        print("=== WithViewStore.\(#function) ===")
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func withViewStore(
        _ index: Int) throws -> InspectableView<ViewType.WithViewStore>
    {
        let file = ViewType.WithViewStore.typePrefix
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
