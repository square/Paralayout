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

    /// Floor a coordinate value (in points) to the nearest pixel, e.g. 0.6 @2x -> 0.5, not 0.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return adjustToPixel(scaleFactor) { floor($0) }
    }

    /// Ceiling a coordinate value (in points) to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 1.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return adjustToPixel(scaleFactor) { ceil($0) }
    }

    /// Round a coordinate value (in points) to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 0.0).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        // Invoke the namespaced Darwin.round() function since round() is ambiguous (it's also a mutating instance
        // method).
        return adjustToPixel(scaleFactor) { Darwin.round($0) }
    }

    // MARK: - Private Methods

    private func adjustToPixel(_ scaleFactor: ScaleFactorProviding, _ adjustment: (CGFloat) -> CGFloat) -> CGFloat {
        let scale = scaleFactor.pixelsPerPoint
        return (scale > 0.0) ? (adjustment(self * scale) / scale) : self
    }

}

extension CGPoint {

    /// Floor a coordinate (in points) to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.floorToPixel(in: scaleFactor), y: y.floorToPixel(in: scaleFactor))
    }

    /// Ceiling a coordinate (in points) to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.ceilToPixel(in: scaleFactor), y: y.ceilToPixel(in: scaleFactor))
    }

    /// Round a coordinate (in points) to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        return CGPoint(x: x.roundToPixel(in: scaleFactor), y: y.roundToPixel(in: scaleFactor))
    }

}

extension CGSize {

    /// Floor a size (in points) to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func floorToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.floorToPixel(in: scaleFactor), height: height.floorToPixel(in: scaleFactor))
    }

    /// Ceiling a size (in points) to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceilToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.ceilToPixel(in: scaleFactor), height: height.ceilToPixel(in: scaleFactor))
    }

    /// Round a size (in points) to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0)).
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(width: width.roundToPixel(in: scaleFactor), height: height.roundToPixel(in: scaleFactor))
    }

}

extension CGRect {

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

}
