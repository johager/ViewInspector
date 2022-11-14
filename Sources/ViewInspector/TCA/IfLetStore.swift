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
            ["ComposableArchitecture", "ComposableArchitecture.IfLetStore"]
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
        let typePrefix = ViewType.IfLetStore.typePrefix
//        print("=== \(typePrefix).\(#function) ===")
        
        // get the IfLetStore content
        guard let viewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: typePrefix) }
        
        let content = Content(viewWithBodyFromClosure.body)
        
        // get the inner WithViewStore content
        guard let innerViewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else {
            // return the IfLetStore "else" content
            return try Inspector.viewsInContainer(view: viewWithBodyFromClosure.body, medium: content.medium)
        }
        
        // return the IfLetStore "if" content
        return try Inspector.viewsInContainer(view: innerViewWithBodyFromClosure.body, medium: content.medium)
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
        let typePrefix = ViewType.IfLetStore.typePrefix
//        print("=== \(#typePrefix).\(#function) - index: \(index) ===")

        let childWrapper = try child(at: index)

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: typePrefix) }

        // this is the IfLetStore content
        let content = Content(viewWithBodyFromClosure.body)
        
        guard let innerViewWithBodyFromClosure = content.view as? (any ViewWithBodyFromClosure)
        else {
            // return the IfLetStore "else" content
            return try .init(content, parent: self, index: index, usesContentFromClosure: true)
        }
        
        // this is the WithViewStore content w/in the IfLetStore content
        let innerContent = Content(innerViewWithBodyFromClosure.body)
        
        return try .init(innerContent, parent: self, index: index, usesContentFromClosure: true)
    }
}
