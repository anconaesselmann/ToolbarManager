//  Created by Axel Ancona Esselmann on 9/13/23.
//

import Foundation

public protocol ToolbarElement: RawRepresentable, Equatable {
    var rawValue: String { get }
}

public enum ToolbarInteraction: Hashable {
    case none
    case set
    case release
    case press

    public var isSet: Bool {
        switch self {
        case .set: return true
        default: return false
        }
    }

    public var isReleased: Bool {
        switch self {
        case .release: return true
        default: return false
        }
    }

    public var isPressed: Bool {
        switch self {
        case .press: return true
        default: return false
        }
    }
}

public enum ToobarButtonType {
    case toggle
    case button
}

internal struct ToolbarEvent {
    let element: any ToolbarElement
    let interaction: ToolbarInteraction
    let disabled: Bool
    let isVisible: Bool
}

public struct AppToolbarEvent<T: ToolbarElement>: Equatable {
    public let element: T
    public let interaction: ToolbarInteraction
    public let disabled: Bool
    public let isVisible: Bool
}
