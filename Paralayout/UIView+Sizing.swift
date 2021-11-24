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
    public struct SizingConstraints: OptionSet {

        // MARK: - Life Cycle

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: - Public Properties

        public let rawValue: UInt

        // MARK: - Public Static Properties

        /// The resulting width will be greater than or equal to the width of the size to fit.
        public static let minWidth = SizingConstraints(rawValue: 1 << 0)
        /// The resulting width will be less than or equal to the width of the size to fit.
        public static let maxWidth = SizingConstraints(rawValue: 1 << 1)
        /// The resulting height will be greater than or equal to the height of the size to fit.
        public static let minHeight = SizingConstraints(rawValue: 1 << 2)
        /// The resulting height will be less than or equal to the height of the size to fit.
        public static let maxHeight = SizingConstraints(rawValue: 1 << 3)

        /// The size will not be adjusted.
        public static let none: SizingConstraints = []

        /// The resulting width will be exactly the width of the size to fit.
        public static let fixedWidth: SizingConstraints = [ minWidth, maxWidth ]
        /// The resulting height will be exactly the height of the size to fit.
        public static let fixedHeight: SizingConstraints = [ minHeight, maxHeight ]

        /// The resulting size will be greater than or equal to the size to fit in both dimensions.
        public static let minSize: SizingConstraints = [ minWidth, minHeight ]
        /// The resulting size will be less than or equal to the size to fit in both dimensions.
        public static let maxSize: SizingConstraints = [ maxWidth, maxHeight ]

        /// The resulting size will be equal in width and less than or equal in height to the size to fit.
        ///
        /// This is most commonly used for views like labels that fill the available width and expand vertically based
        /// on number of lines up until a maximum height.
        public static let wrap: SizingConstraints = [ fixedWidth, maxHeight ]

        // MARK: - Internal Methods

        /// Apply the constraints to a given size.
        ///
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

    /// Returns the bounds size that "best" fits the specified available size with specified constraints applied.
    ///
    /// - parameter size: The available size within which the view should fit. Note that this is not a strict maximum,
    /// but can be enforced using the `constraints`.
    /// - parameter constraints: Constraints to apply to the returned size. Defaults to no constraints.
    /// - returns: A size for the receiver's `bounds` that best fits its content.
    public func sizeThatFits(_ size: CGSize, constraints: SizingConstraints = .none) -> CGSize {
        return constraints.apply(sizeThatFits: sizeThatFits(size), sizeToFit: size)
    }

    /// The bounds size that "best" fits the specified available size with the specified constraints applied.
    ///
    /// - parameter width: The available width within which the view should fit. Defaults to `.greatestFiniteMagnitude`.
    /// - parameter height: The available height within which the view should fit. Defaults to
    /// `.greatestFiniteMagnitude`.
    /// - parameter constraints: Constraints to apply to the returned size. Defaults to no constraints.
    /// - returns: A size for the receiver's `bounds` that best fits its content.
    public func sizeThatFits(
        width: CGFloat = .greatestFiniteMagnitude,
        height: CGFloat = .greatestFiniteMagnitude,
        constraints: SizingConstraints = .none
    ) -> CGSize {
        return sizeThatFits(CGSize(width: width, height: height), constraints: constraints)
    }

    /// Resizes the view to its "ideal" size within the available space (the `sizeToFit`), applying the specified
    /// constraints. The view's final size will never be less than zero in either dimension.
    ///
    /// This method updates the size of the receiver's `bounds`, and is therefore `center`-preserving. Note that this
    /// means the receiver's `frame.origin` may change as a result of calling this method. In a typical layout pass,
    /// this method should be followed by setting the view's position (e.g. through alignment, distribution, etc.).
    ///
    /// - parameter sizeToFit: The size within which to fit, passed through to the view's `sizeThatFits(_:)` method.
    /// - parameter constraints: Constraints on the size to actually set. Defaults to no constraints.
    public func sizeToFit(_ sizeToFit: CGSize, constraints: SizingConstraints = .none) {
        let sizeThatFits = self.sizeThatFits(sizeToFit, constraints: constraints)

        // Setting the bound's width or height to a negative value will result in the origin being shifted by that
        // amount (and the size parameter inverted). This is almost never the behavior we want here, and is difficult to
        // undo later since it requires explicitly setting the bound's origin.
        bounds.size = CGSize(
            width: max(sizeThatFits.width, 0),
            height: max(sizeThatFits.height, 0)
        )
    }

    /// Resizes the view to its "ideal" size within the available space (the specified `width` and `height`), applying
    /// the specified constraints. The view's final size will never be less than zero in either dimension.
    ///
    /// This method updates the size of the receiver's `bounds`, and is therefore `center`-preserving. Note that this
    /// means the receiver's `frame.origin` may change as a result of calling this method. In a typical layout pass,
    /// this method should be followed by setting the view's position (e.g. through alignment, distribution, etc.).
    ///
    /// - parameter width: the width to fit, passed through to the view's `sizeThatFits(_:)` method.
    /// - parameter height: the height to fit, passed through to the view's `sizeThatFits(_:)` method. Defaults to
    /// `.greatestFiniteMagnitude`.
    /// - parameter constraints: Constraints on the size to actually set. Defaults to no constraints.
    public func sizeToFit(
        width: CGFloat,
        height: CGFloat = .greatestFiniteMagnitude,
        constraints: SizingConstraints = .none
    ) {
        sizeToFit(CGSize(width: width, height: height), constraints: constraints)
    }

}
