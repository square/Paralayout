//
//  Copyright © 2017 Square, Inc.
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
    /// - parameter horizontally: Whether to reflect left and right positions (optional, defaults to `true`).
    /// - parameter vertically: Whether to reflect top and bottom positions (optional, defaults to `true`).
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
    /// - parameter rect: The rect for which to interpret the position.
    /// - returns: The point within the rect at the specified position.
    public func point(in rect: CGRect, userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection) -> CGPoint {
        switch ResolvedPosition(resolving: self, with: userInterfaceLayoutDirection) {
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

}

// MARK: -

extension UIView {
    
    // MARK: - View Alignment - Core

    /// The location of a position in the view in the view's `bounds`.
    ///
    /// - parameter position: The position to use.
    /// - returns: The point at the specified position.
    public func point(at position: Position) -> CGPoint {
        return position.point(in: bounds, userInterfaceLayoutDirection: effectiveUserInterfaceLayoutDirection)
    }
    
    /// The offset between two views' positions.
    /// - parameter position: The position in the receiving view's `bounds`.
    /// - parameter otherView: The other view for the measurement.
    /// - parameter otherPosition: The position in the `otherView` to use for the measurement.
    /// - returns: The distance between the two view's positions.
    public func frameOffset(from position: Position, to otherView: UIView, _ otherPosition: Position) -> UIOffset {
        // We can't be aligned to another view if we don't have a superview.
        guard let superview = superview else {
            return .zero
        }
        
        // Convert both points to the receiver's superview, since we are working with the frame (not the bounds).
        let srcPoint = superview.convert(point(at: position), from: self)
        let dstPoint = superview.convert(otherView.point(at: otherPosition), from: otherView)
        
        return dstPoint - srcPoint
    }
    
    /// Move the view to align it with another view.
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter otherView: The view to which the receiving view will be aligned.
    /// - parameter otherPosition: The position within `otherView` to use for alignment.
    /// - parameter offset: An additional offset to apply to the alignment, e.g. to leave a space between the two views.
    public func align(_ position: Position, with otherView: UIView, _ otherPosition: Position, offset: UIOffset) {
        let totalOffset = frameOffset(from: position, to: otherView, otherPosition) + offset
        
        // Apply the offset and round to the nearest pixel.
        frame.origin = (frame.origin + totalOffset).roundToPixel(in: self)
    }
    
    // MARK: - View Alignment - Convenience
    
    /// The insets of the view's positions relative to its superview's.
    public var positionInsetsFromSuperview: UIEdgeInsets {
        // We can't have margins if we don't have a superview.
        guard let superview = superview else {
            return .zero
        }
        
        let leadingOffset = frameOffset(from: .topLeft, to: superview, .topLeft)
        let trailingOffset = frameOffset(from: .bottomRight, to: superview, .bottomRight)
        
        return UIEdgeInsets(
            top: -leadingOffset.vertical,
            left: -leadingOffset.horizontal,
            bottom: trailingOffset.vertical,
            right: trailingOffset.horizontal
        )
    }
    
    /// Move the view to align it with another view.
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter otherView: The view to which the receiving view will be aligned.
    /// - parameter otherPosition: The position within `otherView` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        with otherView: UIView,
        _ otherPosition: Position,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        align(
            position,
            with: otherView,
            otherPosition,
            offset: UIOffset(horizontal: horizontalOffset, vertical: verticalOffset)
        )
    }
    
    /// Move the view to align it within its superview, based on position.
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter superviewPosition: The position within the view's `superview` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        withSuperviewPosition superviewPosition: Position,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        guard let superview = superview else {
            assertionFailure("Can't align view without a superview!")
            return
        }
        
        align(
            position,
            with: superview,
            superviewPosition,
            offset: .init(horizontal: horizontalOffset, vertical: verticalOffset)
        )
    }
    
    /// Move the view to align it within its superview, based on coordinate.
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter superviewPoint: The coordinate within the view's `superview` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        withSuperviewPoint superviewPoint: CGPoint,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        guard let superview = superview else {
            assertionFailure("Can't align view without a superview!")
            return
        }
        
        align(
            position,
            with: superview,
            .topLeft,
            offset: .init(horizontal: superviewPoint.x + horizontalOffset, vertical: superviewPoint.x + verticalOffset)
        )
    }
    
    /// Move the view to align it with another view.
    /// - parameter position: The position in both the receiving view and its `superview` to use for alignment.
    /// - parameter inset: An optional inset (horizontal, vertical, or diagonal based on the position) to apply. An
    /// inset on .center is interpreted as a vertical offset.
    public func alignToSuperview(_ position: Position, inset: CGFloat = 0.0) {
        guard let superview = self.superview else {
            assertionFailure("Can't align view without a superview!")
            return
        }
        
        let offset: UIOffset
        switch ResolvedPosition(resolving: position, with: effectiveUserInterfaceLayoutDirection) {
        case .topLeft:
            offset = UIOffset(horizontal: inset,    vertical: inset)
        case .topCenter:
            offset = UIOffset(horizontal: 0,        vertical: inset)
        case .topRight:
            offset = UIOffset(horizontal: -inset,   vertical: inset)
        case .leftCenter:
            offset = UIOffset(horizontal: inset,    vertical: 0)
        case .center:
            offset = UIOffset(horizontal: 0,        vertical: inset)
        case .rightCenter:
            offset = UIOffset(horizontal: -inset,   vertical: 0)
        case .bottomLeft:
            offset = UIOffset(horizontal: inset,    vertical: -inset)
        case .bottomCenter:
            offset = UIOffset(horizontal: 0,        vertical: -inset)
        case .bottomRight:
            offset = UIOffset(horizontal: -inset,   vertical: -inset)
        }
        
        self.align(position, with: superview, position, offset: offset)
    }
    
}
