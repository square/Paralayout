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


// MARK: - ScaleFactor Protocol


/// The ratio of pixels to points, either of a UIScreen, a UIView's screen, or an explicit value.
public protocol ScaleFactor {
    var pixelsPerPoint: CGFloat { get }
}

extension UIScreen: ScaleFactor {
    public var pixelsPerPoint: CGFloat {
        return scale
    }
}

extension UIView: ScaleFactor {
    public var pixelsPerPoint: CGFloat {
        return (window?.screen ?? UIScreen.main).pixelsPerPoint
    }
}

extension CGFloat: ScaleFactor {
    public var pixelsPerPoint: CGFloat {
        return self
    }
}

extension Int: ScaleFactor {
    public var pixelsPerPoint: CGFloat {
        return CGFloat(self)
    }
}


// MARK: - Pixel-Sensitive Adjustment


public extension CGFloat {
    
    private func adjustToPixel(_ scaleFactor: ScaleFactor, _ adjustment: (CGFloat) -> CGFloat) -> CGFloat {
        let scale = scaleFactor.pixelsPerPoint
        return (scale > 0.0) ? (adjustment(self * scale) / scale) : self
    }
    
    /// Floor a coordinate value (in points) to the nearest pixel, e.g. 0.6 @2x -> 0.5, not 0.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(_ scaleFactor: ScaleFactor) -> CGFloat {
        return adjustToPixel(scaleFactor) { floor($0) }
    }
    
    /// Ceiling a coordinate value (in points) to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 1.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(_ scaleFactor: ScaleFactor) -> CGFloat {
        return adjustToPixel(scaleFactor) { ceil($0) }
    }
    
    /// Round a coordinate value (in points) to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 0.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(_ scaleFactor: ScaleFactor) -> CGFloat {
        // Invoke the namespaced Darwin.round() function since round() is ambiguous (it's also a mutating instance method).
        return adjustToPixel(scaleFactor) { Darwin.round($0) }
    }
    
}


public extension CGPoint {
    
    /// Floor a coordinate (in points) to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(_ scaleFactor: ScaleFactor) -> CGPoint {
        return CGPoint(x: x.floorToPixel(scaleFactor), y: y.floorToPixel(scaleFactor))
    }
    
    /// Ceiling a coordinate (in points) to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(_ scaleFactor: ScaleFactor) -> CGPoint {
        return CGPoint(x: x.ceilToPixel(scaleFactor), y: y.ceilToPixel(scaleFactor))
    }
    
    /// Round a coordinate (in points) to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(_ scaleFactor: ScaleFactor) -> CGPoint {
        return CGPoint(x: x.roundToPixel(scaleFactor), y: y.roundToPixel(scaleFactor))
    }
    
}


public extension CGSize {
    
    /// Floor a size (in points) to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(_ scaleFactor: ScaleFactor) -> CGSize {
        return CGSize(width: width.floorToPixel(scaleFactor), height: height.floorToPixel(scaleFactor))
    }
    
    /// Ceiling a size (in points) to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(_ scaleFactor: ScaleFactor) -> CGSize {
        return CGSize(width: width.ceilToPixel(scaleFactor), height: height.ceilToPixel(scaleFactor))
    }
    
    /// Round a size (in points) to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(_ scaleFactor: ScaleFactor) -> CGSize {
        return CGSize(width: width.roundToPixel(scaleFactor), height: height.roundToPixel(scaleFactor))
    }
    
}


// MARK: - CGRect Convenience Methods


public extension CGRect {
    
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
    
    /// Insets the rect.
    /// - parameter by insets: The UIEdgeInsets to apply.
    /// - returns: A new rect adjusted by the specified insets.
    public func inset(by insets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, insets)
    }
    
    /// Outsets the rect, if necessary, to snap to the nearest pixel at the specified scale.
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosing the original rect.
    public func expandToPixel(_ scaleFactor: ScaleFactor) -> CGRect {
        return CGRect(left: minX.floorToPixel(scaleFactor),
                      top: minY.floorToPixel(scaleFactor),
                      right: maxX.ceilToPixel(scaleFactor),
                      bottom: maxY.ceilToPixel(scaleFactor))
    }
    
    /// Insets the rect, if necessary, to snap to the nearest pixel at the specified scale.
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not* snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosed by the original rect.
    public func contractToPixel(_ scaleFactor: ScaleFactor) -> CGRect {
        return CGRect(left: minX.ceilToPixel(scaleFactor),
                      top: minY.ceilToPixel(scaleFactor),
                      right: maxX.floorToPixel(scaleFactor),
                      bottom: maxY.floorToPixel(scaleFactor))
    }
    
    /// Divides the receiver in two.
    /// - parameter from: The edge from which the amount is interpreted.
    /// - parameter amount: The size of the slice (absolute).
    /// - returns: A tuple (slice: A rect with a width/height of the `amount`, remainder: A rect with a width/height of the receiver reduced by `amount`).
    public func slice(from edge: CGRectEdge, amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        switch edge {
        case .minXEdge:
            // Left.
            assert(amount <= width, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return (CGRect(x: minX, y: minY, width: amount, height: height),
                    CGRect(x: minX + amount, y: minY, width: width - amount, height: height))
            
        case .minYEdge:
            // Top.
            assert(amount <= height, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(CGRect(x: minX, y: minY, width: width, height: amount),
                   CGRect(x: minX, y: minY + amount, width: width, height: height - amount))
            
        case .maxXEdge:
            // Right.
            assert(amount <= width, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(CGRect(x: maxX - amount, y: minY, width: amount, height: height),
                   CGRect(x: minX, y: minY, width: width - amount, height: height))
            
        case .maxYEdge:
            // Bottom.
            assert(amount <= height, "Cannot slice rect \(self) at edge \(edge) by \(amount)!")
            return(CGRect(x: minX, y: maxY - amount, width: width, height: amount),
                   CGRect(x: minX, y: minY, width: width, height: height - amount))
        }
    }

}
