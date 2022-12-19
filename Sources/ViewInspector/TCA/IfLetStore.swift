import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - ViewType.IfLetStore

extension ViewType {
    public struct IfLetStore: KnownViewType {
        public static var typePrefix = "IfLetStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture", "ComposableArchitecture.IfLetStore"]
        }
    }
}

// MARK: - IfLetStore + ViewWithBodyAsContent

extension IfLetStore: ViewWithBodyAsContent { }

// MARK: - ViewType.IfLetStore + SingleViewContent

extension ViewType.IfLetStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.IfLetStore + MultipleViewContent

extension ViewType.IfLetStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        
        // get the IfLetStore content
        guard let viewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.IfLetStore.typePrefix) }
        
        let content = Content(viewWithBodyAsContent.body)
        
        // get the inner WithViewStore content
        guard let innerViewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else {
            // return the IfLetStore "else" content
            return try Inspector.viewsInContainer(view: viewWithBodyAsContent.body, medium: content.medium)
        }
        
        // return the IfLetStore "if" content
        return try Inspector.viewsInContainer(view: innerViewWithBodyAsContent.body, medium: content.medium)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func ifLetStore(
        _ index: Int) throws -> InspectableView<ViewType.IfLetStore>
    {
        let childWrapper = try child(at: index)

        guard let viewWithBodyAsContent = childWrapper.view as? (any ViewWithBodyAsContent)
        else { throw InspectionError.viewNotFound(parent: ViewType.IfLetStore.typePrefix) }

        // this is the IfLetStore content
        let content = Content(viewWithBodyAsContent.body)
        
        guard let innerViewWithBodyAsContent = content.view as? (any ViewWithBodyAsContent)
        else {
            // return the IfLetStore "else" content
            return try .init(content, parent: self, index: index, usesContentFromClosure: true)
        }
        
        // this is the WithViewStore content w/in the IfLetStore content
        let innerContent = Content(innerViewWithBodyAsContent.body)
        
        return try .init(innerContent, parent: self, index: index, usesContentFromClosure: true)
    }
}
