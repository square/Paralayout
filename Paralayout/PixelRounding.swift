//
//  Copyright © 2020 Square, Inc.
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

/// The ratio of pixels to points, either of a UIScreen, a UIView's screen, or an explicit value.
public protocol ScaleFactorProviding {

    var pixelsPerPoint: CGFloat { get }

}

extension UIScreen: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        return scale
    }

}

extension UIView: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        return (window?.screen ?? UIScreen.main).pixelsPerPoint
    }

}

extension CGFloat: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        return self
    }

}

extension Int: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        return CGFloat(self)
    }

}

// MARK: -

extension CGFloat {

    // MARK: - Public Methods

    /// Returns the coordinate value (in points) floored to the nearest pixel, e.g. 0.6 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return adjustedToPixel(scaleFactor) { floor($0) }
    }

    /// Returns the coordinate value (in points) ceiled to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 1.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return adjustedToPixel(scaleFactor) { ceil($0) }
    }

    /// Returns the coordinate value (in points) rounded to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        // Invoke the namespaced Darwin.round() function since round() is ambiguous (it's also a mutating instance
        // method).
        return adjustedToPixel(scaleFactor) { Darwin.round($0) }
    }

    // MARK: - Private Methods

    private func adjustedToPixel(_ scaleFactor: ScaleFactorProviding, _ adjustment: (CGFloat) -> CGFloat) -> CGFloat {
        let scale = scaleFactor.pixelsPerPoint
        return (scale > 0.0) ? (adjustment(self * scale) / scale) : self
    }

}

extension CGPoint {

    /// Returns the coordinate values (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not
    /// (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.flooredToPixel(in: scaleFactor), y: y.flooredToPixel(in: scaleFactor))
    }

    /// Returns the coordinate values (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not
    /// (1.0, 2.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.ceiledToPixel(in: scaleFactor), y: y.ceiledToPixel(in: scaleFactor))
    }

    /// Returns the coordinate values (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not
    /// (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.roundedToPixel(in: scaleFactor), y: y.roundedToPixel(in: scaleFactor))
    }

}

extension CGSize {

    /// Return the size (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.flooredToPixel(in: scaleFactor), height: height.flooredToPixel(in: scaleFactor))
    }

    /// Returns the size (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.ceiledToPixel(in: scaleFactor), height: height.ceiledToPixel(in: scaleFactor))
    }

    /// Returns the size (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.roundedToPixel(in: scaleFactor), height: height.roundedToPixel(in: scaleFactor))
    }

}

extension CGRect {

    /// Returns the rect, outset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosing the original rect.
    public func expandedToPixel(in scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(
            left: minX.flooredToPixel(in: scaleFactor),
            top: minY.flooredToPixel(in: scaleFactor),
            right: maxX.ceiledToPixel(in: scaleFactor),
            bottom: maxY.ceiledToPixel(in: scaleFactor)
        )
    }

    /// Returns the rect, inset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosed by the original rect.
    public func contractedToPixel(in scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(
            left: minX.ceiledToPixel(in: scaleFactor),
            top: minY.ceiledToPixel(in: scaleFactor),
            right: maxX.flooredToPixel(in: scaleFactor),
            bottom: maxY.flooredToPixel(in: scaleFactor)
        )
    }

}
