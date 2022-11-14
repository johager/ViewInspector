import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - ForEachStore + ViewWithBodyFromClosure

extension ForEachStore: ViewWithBodyFromClosure { }

// MARK: - ViewType.ForEachStore

extension ViewType {
    public struct ForEachStore: KnownViewType {
        public static var typePrefix = "ForEachStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture", "ComposableArchitecture.ForEachStore"]
        }
    }
}

// MARK: - ViewType.ForEachStore + SingleViewContent

extension ViewType.ForEachStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
//        print("=== ForEachStore.\(#function) ===")
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.ForEachStore + MultipleViewContent

extension ViewType.ForEachStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let file = ViewType.ForEachStore.typePrefix
//        print("=== \(file).\(#function) ===")
        
//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - content: \(content)")
//        print(">-- --- --- --- -->")
        
        guard let viewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: file) }
        
//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - viewWithBodyFromClosure.body: \(viewWithBodyFromClosure.body)")
//        print(">-- --- --- --- -->")
        
        return try Inspector.viewsInContainer(view: viewWithBodyFromClosure.body, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

extension InspectableView where View: SingleViewContent {
    public func forEachStore() throws -> InspectableView<ViewType.ForEachStore> {
//        print("=== ForEachStore.\(#function) ===")
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func forEachStore(
        _ index: Int) throws -> InspectableView<ViewType.ForEachStore>
    {
        let typePrefix = ViewType.ForEachStore.typePrefix
//        print("=== \(#typePrefix).\(#function) - index: \(index) ===")

        let childWrapper = try child(at: index)

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: typePrefix) }

        let content = Content(viewWithBodyFromClosure.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
