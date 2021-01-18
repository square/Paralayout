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

extension UIView {

    // MARK: - Public Types

    /// Constraints on the result of a call to `sizeThatFits(_:)`.
    /// - `default`: no adjustment.
    /// - `minWidth`: Use the supplied width or larger.
    /// - `maxWidth`: Use the supplied width or smaller.
    /// - `minHeight`: Use the supplied height or larger.
    /// - `maxHeight`: Use the supplied height or smaller.
    /// - `fixedWidth`: Use the supplied width regardless.
    /// - `fixedHeight`: Use the supplied height regardless.
    /// - `minSize`: Use the supplied size or larger.
    /// - `maxSize`: Use the supplied size or smaller.
    /// - `wrap`: Use the supplied width regardless, and the supplied height or smaller.
    public struct SizingConstraints: OptionSet {

        // MARK: - Life Cycle

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: - Public Properties

        public let rawValue: UInt

        // MARK: - Public Static Properties

        public static let minWidth = SizingConstraints(rawValue: 1 << 0)
        public static let maxWidth = SizingConstraints(rawValue: 1 << 1)
        public static let minHeight = SizingConstraints(rawValue: 1 << 2)
        public static let maxHeight = SizingConstraints(rawValue: 1 << 3)

        public static let none: SizingConstraints = []

        public static let fixedWidth: SizingConstraints = [ minWidth, maxWidth ]
        public static let fixedHeight: SizingConstraints = [ minHeight, maxHeight ]

        public static let minSize: SizingConstraints = [ minWidth, minHeight ]
        public static let maxSize: SizingConstraints = [ maxWidth, maxHeight ]
        public static let wrap: SizingConstraints = [ fixedWidth, maxHeight ]

        // MARK: - Internal Methods

        /// Apply the constraints to a given size.
        /// - parameter sizeThatFits: The size to which the constraints should be applied.
        /// - parameter sizeToFit: The size with which to constrain the `sizeThatFits`.
        /// - returns: A size with the receiver's constraints applied.
        func apply(sizeThatFits: CGSize, sizeToFit: CGSize) -> CGSize {
            var constrainedSize = sizeThatFits

            if contains(.minWidth) {
                assert(sizeToFit.width < CGFloat.greatestFiniteMagnitude, "Can't use CGFloat.max with minWidth!")
                constrainedSize.width = max(constrainedSize.width, sizeToFit.width)
            }

            if contains(.maxWidth) {
                constrainedSize.width = min(constrainedSize.width, sizeToFit.width)
            }

            if contains(.minHeight) {
                assert(sizeToFit.height < CGFloat.greatestFiniteMagnitude, "Can't use CGFloat.max with minHeight!")
                constrainedSize.height = max(constrainedSize.height, sizeToFit.height)
            }

            if contains(.maxHeight) {
                constrainedSize.height = min(constrainedSize.height, sizeToFit.height)
            }

            return constrainedSize
        }

    }

    // MARK: - Public Methods

    /// The frame size that "best" fits the supplied bounding size, with constraints applied.
    /// - parameter size: A bounding size within which the view should fit. Not a strict maximum.
    /// - parameter constraints: Limits on the returned size (optional, defaults to `.none`).
    /// - returns: A size for the receiver's `frame` that best fits its content.
    public func sizeThatFits(_ size: CGSize, constraints: SizingConstraints = .none) -> CGSize {
        return constraints.apply(sizeThatFits: sizeThatFits(size), sizeToFit: size)
    }

    /// The frame size that "best" fits the supplied bounding size, with constraints applied.
    /// - parameter width: A bounding width within which the view should fit (optional, defaults to
    /// `.greatestFiniteMagnitude`).
    /// - parameter height: A bounding height within which the view should fit (optional, defaults to
    /// `.greatestFiniteMagnitude`).
    /// - parameter constraints: Limits on the returned size (optional, defaults to `.none`).
    /// - returns: A size for the receiver's `frame` that best fits its content.
    public func sizeThatFits(
        width: CGFloat = .greatestFiniteMagnitude,
        height: CGFloat = .greatestFiniteMagnitude,
        constraints: SizingConstraints = .none
    ) -> CGSize {
        return sizeThatFits(CGSize(width: width, height: height), constraints: constraints)
    }

    /// Set the "ideal" size for the receiver within the available space (the `sizeToFit`), applying the provided
    /// constraints. The view's final size will never be less than zero in either dimension.
    ///
    /// This method updates the size of the receiver's `bounds`, and is therefore `center`-preserving. Note that this
    /// means the receiver's `frame.origin` may change as a result of calling this method.
    ///
    /// - parameter sizeToFit: The size within which to fit, passed through to `sizeThatFits(_:)`.
    /// - parameter constraints: Limits on the size to actually set. Defaults to `.none`.
    public func sizeToFit(_ sizeToFit: CGSize, constraints: SizingConstraints = .none) {
        let sizeThatFits = self.sizeThatFits(sizeToFit, constraints: constraints)

        // Setting the bound's width or height to a negative value will result in the origin being shifted by that
        // amount (and the size parameter inverted). This is almost never the behavior we want here, and is difficult to
        // undo later since it requires explicitly setting the bound's origin.
        bounds.size.width = max(sizeThatFits.width, 0)
        bounds.size.height = max(sizeThatFits.height, 0)
    }

    /// Resize the view to fit a given width.
    /// - parameter width: the width to fit, passed through to `frameSize(thatFits:)`.
    /// - parameter height: the height to fit, passed through to `frameSize(thatFits:)` (optional, defaults to
    /// `greatestFiniteMagnitude`).
    /// - parameter constraints: Limits on the size to actually set (optional, defaults to `.none`).
    public func sizeToFit(
        width: CGFloat,
        height: CGFloat = .greatestFiniteMagnitude,
        constraints: SizingConstraints = .none
    ) {
        sizeToFit(CGSize(width: width, height: height), constraints: constraints)
    }

    /// Resize the view to fit a given size with insets.
    /// - parameter size: The size to fit, typically the `superview.bounds`.
    /// - parameter margins: An inset from the supplied size to use (optional, defaults to `0`).
    public func wrapToFit(_ size: CGSize, margins: CGFloat = 0) {
        sizeToFit(
            CGSize(width: max(0, size.width - 2 * margins), height: max(0, size.height - 2 * margins)),
            constraints: .wrap
        )
    }

    /// Resize the view to a set width, and unlimited height (e.g. when in a scroll view).
    /// - parameter width: the width to set.
    /// - parameter height: the height to fit (optional, defaults to `greatestFiniteMagnitude`).
    /// - parameter margins: An inset from the supplied width to use (optional, defaults to `0`).
    public func wrapToFit(width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, margins: CGFloat = 0) {
        sizeToFit(
            CGSize(width: max(0, width - 2 * margins), height: max(0, height - 2 * margins)),
            constraints: .wrap
        )
    }

}
