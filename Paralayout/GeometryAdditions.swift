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

// MARK: - Operator Overloads

/// Combine two offsets.
public func +(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
    return UIOffset(horizontal: lhs.horizontal + rhs.horizontal, vertical: lhs.vertical + rhs.vertical)
}

/// Scale an offset.
public func *(lhs: UIOffset, rhs: CGFloat) -> UIOffset {
    return UIOffset(horizontal: lhs.horizontal * rhs, vertical: lhs.vertical * rhs)
}

/// Divide an offset.
public func /(lhs: UIOffset, rhs: CGFloat) -> UIOffset {
    return UIOffset(horizontal: lhs.horizontal / rhs, vertical: lhs.vertical / rhs)
}

/// Apply an offset to a point.
public func +(lhs: CGPoint, rhs: UIOffset) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.horizontal, y: lhs.y + rhs.vertical)
}

/// Apply an offset to a CGRect's origin.
public func +(lhs: CGRect, rhs: UIOffset) -> CGRect {
    return CGRect(origin: lhs.origin + rhs, size: lhs.size)
}

/// Get the offset between two points.
public func -(lhs: CGPoint, rhs: CGPoint) -> UIOffset {
    return UIOffset(horizontal: lhs.x - rhs.x, vertical: lhs.y - rhs.y)
}

// MARK: -

extension CGPoint {

    /// Create a point between two other points.
    public init(midpointBetween point1: CGPoint, and point2: CGPoint) {
        self = CGPoint(
            x: (point1.x + point2.x) / 2.0,
            y: (point1.y + point2.y) / 2.0
        )
    }

    /// Returns the straight-line distance to another point.
    public func distance(to point: CGPoint) -> CGFloat {
        return hypot(point.y - y, point.x - x)
    }

}

// MARK: -

extension CGRect {
    
    /// Initialize a CGRect with bounding coordinates (always with non-negative size).
    /// - parameter left: The first vertical edge of the rect.
    /// - parameter top: The first horizontal edge of the rect.
    /// - parameter right: The second vertical edge of the rect.
    /// - parameter bottom: The second horizontal edge of the rect.
    public init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.init(x: min(left, right), y: min(top, bottom), width: abs(right - left), height: abs(bottom - top))
    }
    
    /// Insets the rect's edges.
    /// - parameter left: The inset to apply to the left edge (optional, defaults to 0).
    /// - parameter top: The inset to apply to the top edge (optional, defaults to 0).
    /// - parameter right: The inset to apply to the right edge (optional, defaults to 0).
    /// - parameter bottom: The inset to apply to the bottom edge (optional, defaults to 0).
    /// - returns: A new rect inset by the specified amount(s).
    public func inset(left: CGFloat = 0.0, top: CGFloat = 0.0, right: CGFloat = 0.0, bottom: CGFloat = 0.0) -> CGRect {
        return inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    
    /// Outsets the rect, if necessary, to snap to the nearest pixel at the specified scale.
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosing the original rect.
    public func expandToPixel(_ scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(
            left: minX.floorToPixel(in: scaleFactor),
            top: minY.floorToPixel(in: scaleFactor),
            right: maxX.ceilToPixel(in: scaleFactor),
            bottom: maxY.ceilToPixel(in: scaleFactor)
        )
    }
    
    /// Insets the rect, if necessary, to snap to the nearest pixel at the specified scale.
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosed by the original rect.
    public func contractToPixel(_ scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(
            left: minX.ceilToPixel(in: scaleFactor),
            top: minY.ceilToPixel(in: scaleFactor),
            right: maxX.floorToPixel(in: scaleFactor),
            bottom: maxY.floorToPixel(in: scaleFactor)
        )
    }
    
    /// Divides the receiver in two.
    /// - parameter from: The edge from which the amount is interpreted.
    /// - parameter amount: The size of the slice (absolute).
    /// - returns: A tuple (slice: A rect with a width/height of the `amount`, remainder: A rect with a width/height of
    /// the receiver reduced by `amount`).
    public func slice(from edge: CGRectEdge, amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        switch edge {
        case .minXEdge:
            // Left.
            assert(amount <= width, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return (
                CGRect(x: minX, y: minY, width: amount, height: height),
                CGRect(x: minX + amount, y: minY, width: width - amount, height: height)
            )
            
        case .minYEdge:
            // Top.
            assert(amount <= height, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(
                CGRect(x: minX, y: minY, width: width, height: amount),
                CGRect(x: minX, y: minY + amount, width: width, height: height - amount)
            )
            
        case .maxXEdge:
            // Right.
            assert(amount <= width, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(
                CGRect(x: maxX - amount, y: minY, width: amount, height: height),
                CGRect(x: minX, y: minY, width: width - amount, height: height)
            )
            
        case .maxYEdge:
            // Bottom.
            assert(amount <= height, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(
                CGRect(x: minX, y: maxY - amount, width: width, height: amount),
                CGRect(x: minX, y: minY, width: width, height: height - amount)
            )
        }
    }

}

// MARK: -

extension UIEdgeInsets {
    
    /// The combined top and bottom insets.
    public var verticalAmount: CGFloat {
        return top + bottom
    }
    
    /// The combined left and right insets.
    public var horizontalAmount: CGFloat {
        return left + right
    }

}
