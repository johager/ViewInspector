import Foundation
//import SwiftUI

// MARK: - ViewWithBodyAsContent

public protocol ViewWithBodyAsContent {
    associatedtype Content
    var body: Content { get }
}
