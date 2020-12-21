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

/// A value type representing the ratio between a width and a height.
public struct AspectRatio: Comparable, CustomDebugStringConvertible {

    // MARK: - Public Static Properties

    /// The aspect ratio of a square (1:1).
    public static let square = AspectRatio(width: 1, height: 1)

    /// The golden ratio (~1.618:1).
    public static let golden = AspectRatio(width: (1 + sqrt(5)) / 2, height: 1)

    /// The aspect ratio of HD video, typical for device displays and video (16:9).
    public static let widescreen = AspectRatio(width: 16, height: 9)

    // MARK: - Private Properties

    private let ratioWidth: CGFloat
    private let ratioHeight: CGFloat

    // MARK: - Public Properties

    /// An inverted representation of the AspectRatio.
    public var inverted: AspectRatio {
        return AspectRatio(width: ratioHeight, height: ratioWidth)
    }

    // MARK: - Life Cycle

    /// Creates an AspectRatio with a given `width` and `height`.
    ///
    /// - precondition: Both the `width` and `height` must be greater than zero.
    public init(width: CGFloat, height: CGFloat) {
        precondition(
            width > 0 && height > 0,
            "AspectRatios must be created with a width and height both greater than zero"
        )

        ratioWidth = width
        ratioHeight = height
    }

    /// Creates an AspectRatio matching a given `size`.
    ///
    /// - precondition: Both the `width` and `height` of the `size` must be greater than zero.
    public init(size: CGSize) {
        self.init(width: size.width, height: size.height)
    }

    /// Creates an AspectRatio matching a given `rect`.
    ///
    /// - precondition: Both the `width` and `height` of the `rect` must be greater than zero.
    public init(rect: CGRect) {
        self.init(width: rect.width, height: rect.height)
    }

    // MARK: - Comparable

    public static func == (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return (lhs.ratioWidth * rhs.ratioHeight == lhs.ratioHeight * rhs.ratioWidth)
    }

    public static func < (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return (lhs.ratioWidth * rhs.ratioHeight < lhs.ratioHeight * rhs.ratioWidth)
    }

    public static func <= (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return (lhs.ratioWidth * rhs.ratioHeight <= lhs.ratioHeight * rhs.ratioWidth)
    }

    public static func >= (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return (lhs.ratioWidth * rhs.ratioHeight >= lhs.ratioHeight * rhs.ratioWidth)
    }

    public static func > (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return (lhs.ratioWidth * rhs.ratioHeight > lhs.ratioHeight * rhs.ratioWidth)
    }

    // MARK: - DebugStringConvertible

    public var debugDescription: String {
        return ("AspectRatio<\(ratioWidth):\(ratioHeight)>")
    }

    // MARK: - Public Methods

    /// Returns the height of the aspect ratio for a given `width` rounded to the nearest pixel.
    ///
    /// - parameter width: The desired width.
    /// - parameter scaleFactor: The view/window/screen to use for pixel rounding.
    public func height(forWidth width: CGFloat, in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return (ratioHeight * width / ratioWidth).roundToPixel(in: scaleFactor)
    }

    /// Returns the width of the aspect ratio for a given `height` rounded to the nearest pixel.
    ///
    /// - parameter height: The desired height.
    /// - parameter scaleFactor: The view/window/screen to use for pixel rounding.
    public func width(forHeight height: CGFloat, in scaleFactor: ScaleFactorProviding) -> CGFloat {
        return (ratioWidth * height / ratioHeight).roundToPixel(in: scaleFactor)
    }

    /// Returns a size of the aspect ratio with the specified `width`. The size's `height` will be rounded to the
    /// nearest pixel.
    ///
    /// - parameter width: The desired width.
    /// - parameter scaleFactor: The view/window/screen to use for pixel rounding.
    public func size(forWidth width: CGFloat, in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(
            width: width,
            height: height(forWidth: width, in: scaleFactor)
        )
    }

    /// Returns a size of the aspect ratio with the specified `height`. The size's `width` will be rounded to the
    /// nearest pixel.
    ///
    /// - parameter height: The desired height.
    /// - parameter scaleFactor: The view/window/screen to use for pixel rounding.
    public func size(forHeight height: CGFloat, in scaleFactor: ScaleFactorProviding) -> CGSize {
        return CGSize(
            width: width(forHeight: height, in: scaleFactor),
            height: height
        )
    }

    /// An "aspect-fit" function that determines the largest size of the receiver's aspect ratio that fits within a
    /// size.
    ///
    /// - parameter size: The bounding size.
    /// - parameter scaleFactor: The view/window/screen to use for pixel alignment.
    /// - returns: A size with the receiver's aspect ratio, no larger than the bounding size.
    public func size(toFit size: CGSize, in scaleFactor: ScaleFactorProviding) -> CGSize {
        if size.aspectRatio <= self {
            // Match width, narrow the height.
            let fitHeight = min(size.height, height(forWidth: size.width, in: scaleFactor))
            return CGSize(width: size.width, height: fitHeight)

        } else {
            // Match height, narrow the width.
            let fitWidth = min(size.width, width(forHeight: size.height, in: scaleFactor))
            return CGSize(width: fitWidth, height: size.height)
        }
    }

    /// An "aspect-fit" function that determines the largest rect of the receiver's aspect ratio that fits within a
    /// rect.
    ///
    /// - parameter rect: The bounding rect.
    /// - parameter position: The location within the bounding rect for the new rect, determining where margin(s) will
    /// be if the aspect ratios do not match perfectly.
    /// - parameter scaleFactor: The view/window/screen to use for pixel alignment.
    /// - returns: A rect with the receiver's aspect ratio, strictly within the bounding rect.
    public func rect(toFit rect: CGRect, at position: Position, in scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(size: size(toFit: rect.size, in: scaleFactor), at: position, of: rect, in: scaleFactor)
    }

    /// An "aspect-fill" function that determines the smallest size of the receiver's aspect ratio that fits a size
    /// within it.
    ///
    /// - parameter size: The bounding size.
    /// - parameter scaleFactor: The view/window/screen to use for pixel alignment.
    /// - returns: A size with the receiver's aspect ratio, at least as large as the bounding size.
    public func size(toFill size: CGSize, in scaleFactor: ScaleFactorProviding) -> CGSize {
        if size.aspectRatio <= self {
            // Match height, expand the width.
            let fillWidth = width(forHeight: size.height, in: scaleFactor)
            return CGSize(width: fillWidth, height: size.height)

        } else {
            // Match width, expand the height.
            let fillHeight = height(forWidth: size.width, in: scaleFactor)
            return CGSize(width: size.width, height: fillHeight)
        }
    }

    /// An "aspect-fill" function that determines the smallest rect of the receiver's aspect ratio that fits a rect
    /// within it.
    ///
    /// - parameter rect: The bounding rect.
    /// - parameter position: The location within the bounding rect for the new rect, determining where margin(s) will
    /// be if the aspect ratios do not match perfectly.
    /// - parameter scaleFactor: The view/window/screen to use for pixel alignment.
    /// - returns: A rect with the receiver's aspect ratio, strictly containing the bounding rect.
    public func rect(toFill rect: CGRect, at position: Position, in scaleFactor: ScaleFactorProviding) -> CGRect {
        return CGRect(size: size(toFill: rect.size, in: scaleFactor), at: position, of: rect, in: scaleFactor)
    }

}

// MARK: -

extension CGSize {

    /// The aspect ratio of this size.
    public var aspectRatio: AspectRatio {
        return AspectRatio(size: self)
    }

}

extension CGRect {

    // MARK: - Public Properties

    /// The aspect ratio of this rect's size.
    public var aspectRatio: AspectRatio {
        return AspectRatio(size: size)
    }

    // MARK: - Life Cycle

    fileprivate init(
        size newSize: CGSize,
        at position: Position,
        of alignmentRect: CGRect,
        in scaleFactor: ScaleFactorProviding
    ) {
        let newOrigin: CGPoint

        if newSize.width == alignmentRect.width {
            // The width matches; position vertically.
            let newMinY: CGFloat
            switch position {
            case .topLeft, .topCenter, .topRight:
                newMinY = alignmentRect.minY
            case .leftCenter, .center, .rightCenter:
                newMinY = (alignmentRect.midY - newSize.height / 2).roundToPixel(in: scaleFactor)
            case .bottomLeft, .bottomCenter, .bottomRight:
                newMinY = alignmentRect.maxY - newSize.height
            }

            newOrigin = CGPoint(x: alignmentRect.minX, y: newMinY)

        } else {
            // The height matches; position horizontally.
            let newMinX: CGFloat
            switch position {
            case .topLeft, .leftCenter, .bottomLeft:
                newMinX = alignmentRect.minX
            case .topCenter, .center, .bottomCenter:
                newMinX = (alignmentRect.midX - newSize.width / 2).roundToPixel(in: scaleFactor)
            case .topRight, .rightCenter, .bottomRight:
                newMinX = alignmentRect.maxX - newSize.width
            }

            newOrigin = CGPoint(x: newMinX, y: alignmentRect.minY)
        }

        self.init(origin: newOrigin, size: newSize)
    }

}
