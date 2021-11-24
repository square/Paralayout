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

/// A direction for subview distribution.
public enum ViewDistributionAxis {

    /// The horizontal direction, meaning views will be distributed left-to-right or right-to-left.
    case horizontal

    /// The vertical direction, meaning views will be distributed top-to-bottom.
    case vertical

    // MARK: - Internal Methods

    internal func amount(of insets: UIEdgeInsets) -> CGFloat {
        switch self {
        case .horizontal:
            return insets.horizontalAmount
        case .vertical:
            return insets.verticalAmount
        }
    }

    internal func size(of rect: CGRect) -> CGFloat {
        switch self {
        case .horizontal:
            return rect.width
        case .vertical:
            return rect.height
        }
    }

    internal func leadingEdge(of rect: CGRect, layoutDirection: UIUserInterfaceLayoutDirection) -> CGFloat {
        switch (self, layoutDirection) {
        case (.horizontal, .leftToRight):
            return rect.minX
        case (.horizontal, .rightToLeft):
            return rect.maxX
        case (.vertical, _):
            return rect.minY
        @unknown default:
            fatalError("Unknown user interface layout direction")
        }
    }

    internal func trailingEdge(
        of rect: CGRect,
        layoutDirection: UIUserInterfaceLayoutDirection,
        extendedBy additionalDistance: CGFloat = 0
    ) -> CGFloat {
        switch (self, layoutDirection) {
        case (.horizontal, .leftToRight):
            return rect.maxX + additionalDistance
        case (.horizontal, .rightToLeft):
            return rect.minX - additionalDistance
        case (.vertical, _):
            return rect.maxY + additionalDistance
        @unknown default:
            fatalError("Unknown user interface layout direction")
        }
    }

    internal func setSize(_ size: CGFloat, ofRect rect: inout CGRect) {
        switch self {
        case .horizontal:
            rect.size.width = size
        case .vertical:
            rect.size.height = size
        }
    }

    internal func setLeadingEdge(
        _ leadingEdge: CGFloat,
        ofRect rect: inout CGRect,
        layoutDirection: UIUserInterfaceLayoutDirection
    ) {
        switch (self, layoutDirection) {
        case (.horizontal, .leftToRight):
            rect.origin.x = leadingEdge
        case (.horizontal, .rightToLeft):
            rect.origin.x = leadingEdge + rect.width
        case (.vertical, _):
            rect.origin.y = leadingEdge
        @unknown default:
            fatalError("Unknown user interface layout direction")
        }
    }

}

/// Orthogonal alignment options for view distribution.
public enum ViewDistributionAlignment {

    /// Align to the leading edge (for vertical distribution) or top (for horizontal).
    ///
    /// - inset: An inset from the leading edge towards the center of the distribution axis.
    case leading(inset: CGFloat)

    /// Center-align along the distribution axis.
    ///
    /// - offset: An offset from the center of the distribution axis. Positive values indicate adjusting towards the
    /// trailing edge. Negative values indicate adjusting towards the leading edge.
    case centered(offset: CGFloat)

    /// Align to the trailing edge (for vertical distribution) or bottom (for horizontal).
    ///
    /// - inset: An inset from the trailing edge towards the center of the distribution axis.
    case trailing(inset: CGFloat)

}

// MARK: -

extension UIView {

    /// Arrange subviews according to a distribution with fixed and/or flexible spacers. Examples:
    ///
    /// To stack two elements (no `.flexible` items implies vertically centering the group):
    /// `applySubviewDistribution([ icon, 10.fixed, label ])`
    ///
    /// To evenly spread out items (no spacers implies equal space between all elements):
    /// `applySubviewDistribution([ button1, button2, button3 ])`
    ///
    /// To stack two elements with 50% more space below than above:
    /// `applySubviewDistribution([ 2.flexible, label, 12.fixed, textField, 3.flexible ])`
    ///
    /// To arrange a pair of buttons on the left and right edges of a view, with a label centered between them:
    /// ```
    /// applySubviewDistribution(
    ///     [ 8.fixed, backButton, 1.flexible, titleLabel, 1.flexible, nextButton, 8.fixed ],
    ///     axis: .horizontal
    /// )
    /// ```
    ///
    /// To arrange UI in a view with an interior margin.
    /// `applySubviewDistribution([ icon, 10.fixed, label ], inRect: bounds.insetBy(dx: 20, dy: 40))`
    ///
    /// To arrange UI vertically without simultaneously centering it horizontally (the `icon` would need independent
    /// horizontal positioning).
    /// `applySubviewDistribution([ 1.flexible, icon, 2.flexible ], orthogonalOffset: nil)`
    ///
    /// - precondition: All views in the `distribution` must be subviews of the receiver.
    /// - precondition: The `distribution` must not include any given view more than once.
    ///
    /// - parameter distribution: An array of distribution specifiers, ordered from the leading/top edge to the
    /// trailing/bottom edge.
    /// - parameter axis: The axis upon which the items should be distributed. Defaults to `.vertical`.
    /// - parameter layoutBounds: The region in the receiver in which to distribute the view. Specify `nil` to use the
    /// receiver's bounds. Defaults to `nil`.
    /// - parameter orthogonalAlignment: The alignment (orthogonal to the distribution axis) to apply to the views. If
    /// `nil`, views are not moved orthogonally. Defaults to centered with no offset.
    public func applySubviewDistribution(
        _ distribution: [ViewDistributionSpecifying],
        axis: ViewDistributionAxis = .vertical,
        inRect layoutBounds: CGRect? = nil,
        alignment orthogonalAlignment: ViewDistributionAlignment? = .centered(offset: 0)
    ) {
        // Process and validate the distribution.
        let (items, totalFixedSpace, flexibleSpaceDenominator) = ViewDistributionItem.items(
            impliedIn: distribution,
            axis: axis,
            superview: self
        )

        guard items.count > 0 else {
            return
        }

        // Determine the layout parameters based on the space the distribution is going into.
        let layoutBounds = layoutBounds ?? bounds
        let flexibleSpaceMultiplier = (axis.size(of: layoutBounds) - totalFixedSpace) / flexibleSpaceDenominator
        let receiverLayoutDirection = effectiveUserInterfaceLayoutDirection

        // Okay, ready to go!
        var viewOrigin = axis.leadingEdge(of: layoutBounds, layoutDirection: receiverLayoutDirection)
        for item in items {
            switch item {
            case .view(let subview, let insets):
                var frame = subview.untransformedFrame

                switch axis {
                case .horizontal:
                    frame.origin.x = (viewOrigin - insets.left).roundedToPixel(in: self)

                    if let verticalAlignment = orthogonalAlignment {
                        switch verticalAlignment {
                        case .leading(inset: let inset):
                            frame.origin.y = (layoutBounds.minY + inset).roundedToPixel(in: self)
                        case .centered(offset: let offset):
                            frame.origin.y = (layoutBounds.midY - frame.height / 2 + offset).roundedToPixel(in: self)
                        case .trailing(inset: let inset):
                            frame.origin.y = (layoutBounds.maxY - (frame.height + inset)).roundedToPixel(in: self)
                        }
                    }

                case .vertical:
                    frame.origin.y = (viewOrigin - insets.top).roundedToPixel(in: self)

                    if let horizontalAlignment = orthogonalAlignment {
                        switch (horizontalAlignment, receiverLayoutDirection) {
                        case let (.leading(inset: inset), .leftToRight):
                            frame.origin.x = (layoutBounds.minX + inset).roundedToPixel(in: self)
                        case let (.leading(inset: inset), .rightToLeft):
                            frame.origin.x = (layoutBounds.maxX - (frame.width + inset)).roundedToPixel(in: self)
                        case let (.centered(offset: offset), .leftToRight):
                            frame.origin.x = (layoutBounds.midX - frame.width / 2 + offset).roundedToPixel(in: self)
                        case let (.centered(offset: offset), .rightToLeft):
                            frame.origin.x = (layoutBounds.midX - frame.width / 2 - offset).roundedToPixel(in: self)
                        case let (.trailing(inset: inset), .leftToRight):
                            frame.origin.x = (layoutBounds.maxX - (frame.width + inset)).roundedToPixel(in: self)
                        case let (.trailing(inset: inset), .rightToLeft):
                            frame.origin.x = (layoutBounds.minX + inset).roundedToPixel(in: self)
                        @unknown default:
                            fatalError("Unknown user interface layout direction")
                        }
                    }
                }

                subview.untransformedFrame = frame

            case .fixed, .flexible:
                break
            }

            let distanceToMoveOrigin: CGFloat
            if item.isFlexible {
                // Note that we don't round/floor here, but rather when setting the position of each subview
                // individually, so that rounding error is not accumulated.
                distanceToMoveOrigin = item.layoutSize(along: axis, multiplier: flexibleSpaceMultiplier)

            } else {
                distanceToMoveOrigin = item.layoutSize(along: axis)
            }

            switch (axis, receiverLayoutDirection) {
            case (.horizontal, .leftToRight), (.vertical, _):
                viewOrigin += distanceToMoveOrigin
            case (.horizontal, .rightToLeft):
                viewOrigin -= distanceToMoveOrigin
            @unknown default:
                fatalError("Unknown user interface layout direction")
            }
        }
    }

}
