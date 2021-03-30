//
//  Copyright © 2021 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

/// Locations within a rectangle.
public enum Position {

    case topLeft, topCenter, topRight
    case leftCenter, center, rightCenter
    case bottomLeft, bottomCenter, bottomRight

    case topLeading, topTrailing
    case leadingCenter, trailingCenter
    case bottomLeading, bottomTrailing

    // MARK: - Public Methods

    /// The "opposite" position.
    ///
    /// Direction-agnostic positions (those defined with left and right) will be swapped with other direction-agnostic
    /// positions. Likewise direction-aware positions (those defined leading and trailing) will be swapped with other
    /// direction-aware positions.
    ///
    /// - parameter horizontally: Whether to reflect positions across the Y axis (where the origin is at the center of
    /// the rect).
    /// - parameter vertically: Whether to reflect positions across the X axis (where the origin is at the center of the
    /// rect).
    /// - returns: A position on the opposite side/corner as specified.
    public func reflected(horizontally: Bool = true, vertically: Bool = true) -> Position {
        switch self {
        case .topLeft:
            if horizontally {
                return vertically ? .bottomRight : .topRight
            } else {
                return vertically ? .bottomLeft : .topLeft
            }

        case .topCenter:
            return vertically ? .bottomCenter : .topCenter

        case .topRight:
            if horizontally {
                return vertically ? .bottomLeft : .topLeft
            } else {
                return vertically ? .bottomRight : .topRight
            }

        case .leftCenter:
            return horizontally ? .rightCenter : .leftCenter

        case .center:
            return .center

        case .rightCenter:
            return horizontally ? .leftCenter : .rightCenter

        case .bottomLeft:
            if horizontally {
                return vertically ? .topRight : .bottomRight
            } else {
                return vertically ? .topLeft : .bottomLeft
            }

        case .bottomCenter:
            return vertically ? .topCenter : .bottomCenter

        case .bottomRight:
            if horizontally {
                return vertically ? .topLeft : .bottomLeft
            } else {
                return vertically ? .topRight : .bottomRight
            }

        case .topLeading:
            if horizontally {
                return vertically ? .bottomTrailing : .topTrailing
            } else {
                return vertically ? .bottomLeading : .topLeading
            }

        case .topTrailing:
            if horizontally {
                return vertically ? .bottomLeading : .topLeading
            } else {
                return vertically ? .bottomTrailing : .topTrailing
            }

        case .leadingCenter:
            return horizontally ? .trailingCenter : .leadingCenter

        case .trailingCenter:
            return horizontally ? .leadingCenter : .trailingCenter

        case .bottomLeading:
            if horizontally {
                return vertically ? .topTrailing : .bottomTrailing
            } else {
                return vertically ? .topLeading : .bottomLeading
            }

        case .bottomTrailing:
            if horizontally {
                return vertically ? .topLeading : .bottomLeading
            } else {
                return vertically ? .topTrailing : .bottomTrailing
            }
        }
    }

    /// The position in a specific rectangle.
    ///
    /// - parameter rect: The rect for which to interpret the position.
    /// - parameter layoutDirection: The layout direction of the view in which the rect is defined. Used to resolve
    /// leading and trailing positions.
    /// - returns: The point within the rect at the specified position.
    public func point(in rect: CGRect, layoutDirection: UIUserInterfaceLayoutDirection) -> CGPoint {
        switch ResolvedPosition(resolving: self, with: layoutDirection) {
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)

        case .topCenter:
            return CGPoint(x: rect.midX, y: rect.minY)

        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)

        case .leftCenter:
            return CGPoint(x: rect.minX, y: rect.midY)

        case .center:
            return CGPoint(x: rect.midX, y: rect.midY)

        case .rightCenter:
            return CGPoint(x: rect.maxX, y: rect.midY)

        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)

        case .bottomCenter:
            return CGPoint(x: rect.midX, y: rect.maxY)

        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }

}

// MARK: -

internal enum ResolvedPosition {

    case topLeft, topCenter, topRight
    case leftCenter, center, rightCenter
    case bottomLeft, bottomCenter, bottomRight

    init(resolving position: Position, with layoutDirection: UIUserInterfaceLayoutDirection) {
        switch (position, layoutDirection) {
        case (.topLeft, _),
             (.topLeading, .leftToRight),
             (.topTrailing, .rightToLeft):
            self = .topLeft

        case (.topCenter, _):
            self = .topCenter

        case (.topRight, _),
             (.topLeading, .rightToLeft),
             (.topTrailing, .leftToRight):
            self = .topRight

        case (.leftCenter, _),
             (.leadingCenter, .leftToRight),
             (.trailingCenter, .rightToLeft):
            self = .leftCenter

        case (.center, _):
            self = .center

        case (.rightCenter, _),
             (.leadingCenter, .rightToLeft),
             (.trailingCenter, .leftToRight):
            self = .rightCenter

        case (.bottomLeft, _),
             (.bottomLeading, .leftToRight),
             (.bottomTrailing, .rightToLeft):
            self = .bottomLeft

        case (.bottomCenter, _):
            self = .bottomCenter

        case (.bottomRight, _),
             (.bottomLeading, .rightToLeft),
             (.bottomTrailing, .leftToRight):
            self = .bottomRight

        @unknown default:
            fatalError("Unknown user interface layout direction")
        }
    }

    var layoutDirectionAgnosticPosition: Position {
        switch self {
        case .topLeft:
            return .topLeft
        case .topCenter:
            return .topCenter
        case .topRight:
            return .topRight
        case .leftCenter:
            return .leftCenter
        case .center:
            return .center
        case .rightCenter:
            return .rightCenter
        case .bottomLeft:
            return .bottomLeft
        case .bottomCenter:
            return .bottomCenter
        case .bottomRight:
            return .bottomRight
        }
    }

}
