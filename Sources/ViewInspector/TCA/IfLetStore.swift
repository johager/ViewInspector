import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - IfLetStore + ViewWithBodyFromClosure

extension IfLetStore: ViewWithBodyFromClosure { }

// MARK: - ViewType.IfLetStore

extension ViewType {
    public struct IfLetStore: KnownViewType {
        public static var typePrefix = "IfLetStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture"]
        }
    }
}

// MARK: - ViewType.IfLetStore + SingleViewContent

extension ViewType.IfLetStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
//        print("=== IfLetStore.\(#function) ===")
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.IfLetStore + MultipleViewContent

extension ViewType.IfLetStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
//        print("=== IfLetStore.\(#function) ===")
        return try Inspector.viewsInContainer(view: content.view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

extension InspectableView where View: SingleViewContent {
    public func ifLetStore() throws -> InspectableView<ViewType.IfLetStore> {
//        print("=== IfLetStore.\(#function) ===")
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func ifLetStore(
        _ index: Int) throws -> InspectableView<ViewType.IfLetStore>
    {
        let file = ViewType.IfLetStore.typePrefix
//        print("=== \(#file).\(#function) - index: \(index) ===")

        let childWrapper = try child(at: index)
//        print("--- \(file).\(#function) - index: \(index), childWrapper: \(childWrapper)")

//        print("--- \(file).\(#function) - index: \(index), childWrapper.view: \(childWrapper.view)")

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: file) }

//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - viewWithBodyFromClosure: \(viewWithBodyFromClosure)")
//        print(">-- --- --- --- -->")

        // this is the IfLetStore content
        let content = Content(viewWithBodyFromClosure.body)
        
//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - content: \(content)")
//        print(">-- --- --- --- -->")
        
        guard let innerViewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else {
//            throw InspectionError.viewNotFound(parent: file)
            // return the IfLetStore "else" content
            return try .init(content, parent: self, index: index, usesContentFromClosure: true)
        }
        
//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - innerViewWithBodyFromClosure: \(innerViewWithBodyFromClosure)")
//        print(">-- --- --- --- -->")
        
        // this is the WithViewStore content w/in the IfLetStore content
        let innerContent = Content(innerViewWithBodyFromClosure.body)
        
//        print(">-- --- --- --- -->")
//        print("--- \(file).\(#function) - innerContent: \(innerContent)")
//        print(">-- --- --- --- -->")
        
        return try .init(innerContent, parent: self, index: index, usesContentFromClosure: true)
    }
}
