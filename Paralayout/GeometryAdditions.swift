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

    /// Returns the offset that would need to be applied to the receiver to reach the specified `point`.
    public func offset(to point: CGPoint) -> UIOffset {
        return UIOffset(
            horizontal: point.x - self.x,
            vertical: point.y - self.y
        )
    }

    /// Returns the offset that would need to be applied to the `point` to reach the receiver.
    public func offset(from point: CGPoint) -> UIOffset {
        return point.offset(to: self)
    }

    /// Returns the point offset from the receiver by the specified `offset`.
    public func offset(by offset: UIOffset) -> CGPoint {
        return CGPoint(x: self.x + offset.horizontal, y: self.y + offset.vertical)
    }

}

// MARK: -

extension CGSize {

    // MARK: - Public Static Properties

    public static let greatestFiniteMagnitude: CGSize = .init(
        width: CGFloat.greatestFiniteMagnitude,
        height: CGFloat.greatestFiniteMagnitude
    )

    // MARK: - Operators

    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
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
    public func insetBy(left: CGFloat = 0.0, top: CGFloat = 0.0, right: CGFloat = 0.0, bottom: CGFloat = 0.0) -> CGRect {
        return inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

    /// Insets the rect equally on all sides.
    /// - parameter inset: The amount by which to contract each edge of the receiver.
    /// - returns: A new rect with the inset applied.
    public func insetAllSides(by inset: CGFloat) -> CGRect {
        return insetBy(dx: inset, dy: inset)
    }

    /// Add additional padding to the outside of the receiver.
    ///
    /// This is the inverse of the `inset(by:)` method.
    ///
    /// - parameter insets: The amount by which to expand each edge of the receiver.
    /// - returns: A new rect with the outset applied.
    public func outset(by insets: UIEdgeInsets) -> CGRect {
        let outsets = UIEdgeInsets(
            top: -insets.top,
            left: -insets.left,
            bottom: -insets.bottom,
            right: -insets.right
        )

        return inset(by: outsets)
    }

    /// Returns the rect of the same size of the receiver whose origin is offset from the receiver's origin by the
    /// specified `offset`.
    public func offset(by offset: UIOffset) -> CGRect {
        return CGRect(origin: origin.offset(by: offset), size: size)
    }
    
    /// Divides the receiver in two.
    ///
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

    /// Returns the point in the receiver at the specified position.
    public func point(at position: Position, layoutDirection: UIUserInterfaceLayoutDirection) -> CGPoint {
        return position.point(in: self, layoutDirection: layoutDirection)
    }

}

// MARK: -

extension UIEdgeInsets {

    /// Initialize edge insets with the same amount inset on each edge.
    ///
    /// - parameter inset: The amount by which to inset each edge.
    public init(uniform inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// Initialize edge insets with the same amount outset on each edge.
    ///
    /// This is the inverse of `init(uniform:)`.
    ///
    /// - parameter outset: The amount by which to outset each edge.
    public init(uniformOutset outset: CGFloat) {
        self.init(uniform: -outset)
    }

    /// Initialize edge insets with `vertical` insets on the top and bottom edges and `horizontal` insets on the left
    /// and right edges.
    ///
    /// - parameter vertical: The amount by which to inset the top and bottom edges.
    /// - parameter horizontal: The amount by which to inset the left and right edges.
    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }

    /// The combined top and bottom insets.
    public var verticalAmount: CGFloat {
        return top + bottom
    }
    
    /// The combined left and right insets.
    public var horizontalAmount: CGFloat {
        return left + right
    }

}

// MARK: -

extension NSDirectionalEdgeInsets {

    /// Initialize edge insets with the same amount inset on each side.
    ///
    /// - parameter inset: The amount by which to inset each edge.
    public init(uniform inset: CGFloat) {
        self.init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }

    /// Initialize edge insets with the same amount outset on each edge.
    ///
    /// This is the inverse of `init(uniform:)`.
    ///
    /// - parameter outset: The amount by which to outset each side.
    public init(uniformOutset outset: CGFloat) {
        self.init(uniform: -outset)
    }

    /// Initialize edge insets with `vertical` insets on the top and bottom edges and `horizontal` insets on the leading
    /// and trailing edges.
    ///
    /// - parameter vertical: The amount by which to inset the top and bottom edges.
    /// - parameter horizontal: The amount by which to inset the leading and trailing edges.
    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    /// The combined top and bottom insets.
    public var verticalAmount: CGFloat {
        return top + bottom
    }

    /// The combined leading and trailing insets.
    public var horizontalAmount: CGFloat {
        return leading + trailing
    }

}
