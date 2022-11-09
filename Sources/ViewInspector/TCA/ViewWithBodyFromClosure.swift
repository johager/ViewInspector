import Foundation
//import SwiftUI

// MARK: - ViewWithBodyFromClosure

public protocol ViewWithBodyFromClosure {
    associatedtype Content
    var body: Content { get }
}
