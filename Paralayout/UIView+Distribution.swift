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

/// Orthogonal alignment options for horizontal view distribution.
public enum VerticalDistributionAlignment {

    /// Align to the top edge, inset by the specified amount.
    ///
    /// - inset: An inset from the top edge towards the center of the distribution axis.
    case top(inset: CGFloat)

    /// Center-align along the distribution axis.
    ///
    /// - offset: An offset from the center of the distribution axis. Positive values indicate adjusting towards the
    /// top edge. Negative values indicate adjusting towards the bottom edge.
    case centered(offset: CGFloat)

    /// Align to the bottom edge, inset by the specified amount.
    ///
    /// - inset: An inset from the bottom edge towards the center of the distribution axis.
    case bottom(inset: CGFloat)

}

/// Orthogonal alignment options for vertical view distribution.
public enum HorizontalDistributionAlignment {

    /// Align to the leading edge, inset by the specified amount.
    ///
    /// - inset: An inset from the leading edge towards the center of the distribution axis.
    case leading(inset: CGFloat)

    /// Center-align along the distribution axis.
    ///
    /// - offset: An offset from the center of the distribution axis. Positive values indicate adjusting towards the
    /// trailing edge. Negative values indicate adjusting towards the leading edge.
    case centered(offset: CGFloat)

    /// Align to the trailing edge, inset by the specified amount.
    ///
    /// - inset: An inset from the trailing edge towards the center of the distribution axis.
    case trailing(inset: CGFloat)

}

// MARK: -

extension UIView {

    // MARK: - Public Methods

    /// Arranges subviews along the vertical axis according to a distribution with fixed and/or flexible spacers.
    ///
    /// * If there are no flexible elements, this will treat the distribution as vertically centered (i.e. with two
    /// flexible elements of equal weight at the top and bottom, respectively).
    /// * If there are no spacers (fixed or flexible), this will treat the distribution as equal flexible spacing
    /// at the top, bottom, and between each view.
    ///
    /// **Examples:**
    ///
    /// To stack two elements with a 10 pt margin between them:
    /// ```
    /// // This is effectively the same as [ 1.flexible, icon, 10.fixed, label, 1.flexible ].
    /// applyVerticalSubviewDistribution([ icon, 10.fixed, label ])
    /// ```
    ///
    /// To evenly spread out items:
    /// ```
    /// // This is effectively the same as [ 1.flexible, button1, 1.flexible, button2, 1.flexible, button3 ].
    /// applyVerticalSubviewDistribution([ button1, button2, button3 ])
    /// ```
    ///
    /// To stack two elements with 50% more space below than above:
    /// ```
    /// applyVerticalSubviewDistribution([ 2.flexible, label, 12.fixed, textField, 3.flexible ])
    /// ```
    ///
    /// To arrange a pair of label on the top and bottom edges of a view, with another label centered between them:
    /// ```
    /// applyVerticalSubviewDistribution(
    ///     [ 8.fixed, headerLabel, 1.flexible, bodyLabel, 1.flexible, footerLabel, 8.fixed ]
    /// )
    /// ```
    ///
    /// To arrange UI in a view with an interior margin:
    /// ```
    /// applyVerticalSubviewDistribution([ icon, 10.fixed, label ], inRect: bounds.insetBy(dx: 20, dy: 40))
    /// ```
    ///
    /// To arrange UI vertically aligned by their leading edge 10 pt in from the leading edge of their superview:
    /// ```
    /// applyVerticalSubviewDistribution([ icon, 1.flexible, button ], orthogonalOffset: .leading(inset: 10))
    /// ```
    ///
    /// To arrange UI vertically without simultaneously centering it horizontally (the `icon` would need independent
    /// horizontal positioning):
    /// ```
    /// applyVerticalSubviewDistribution([ 1.flexible, icon, 2.flexible ], orthogonalOffset: nil)
    /// ```
    ///
    /// - precondition: All views in the `distribution` must be subviews of the receiver.
    /// - precondition: The `distribution` must not include any given view more than once.
    ///
    /// - parameter distribution: An array of distribution specifiers, ordered from the top edge to the bottom edge.
    /// - parameter layoutBounds: The region in the receiver in which to distribute the view in the receiver's
    /// coordinate space. Specify `nil` to use the receiver's bounds. Defaults to `nil`.
    /// - parameter orthogonalAlignment: The horizontal alignment to apply to the views. If `nil`, views are left in
    /// their horizontal position prior to the distribution. Defaults to centered with no offset.
    public func applyVerticalSubviewDistribution(
        _ distribution: [ViewDistributionSpecifying],
        inRect layoutBounds: CGRect? = nil,
        orthogonalAlignment: HorizontalDistributionAlignment? = .centered(offset: 0)
    ) {
        applySubviewDistribution(distribution, axis: .vertical, inRect: layoutBounds) { frame, layoutBounds in
            guard let horizontalAlignment = orthogonalAlignment else {
                return
            }

            switch (horizontalAlignment, effectiveUserInterfaceLayoutDirection) {
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

    /// Arranges subviews along the horizontal axis according to a distribution with fixed and/or flexible spacers.
    ///
    /// * If there are no flexible elements, this will treat the distribution as horizontally centered (i.e. with two
    /// flexible elements of equal weight at the leading and trailing edges, respectively).
    /// * If there are no spacers (fixed or flexible), this will treat the distribution as equal flexible spacing
    /// at the leading edge, trailing edge, and between each view.
    ///
    /// **Examples:**
    ///
    /// To stack two elements with a 10 pt margin between them:
    /// ```
    /// // This is effectively the same as [ 1.flexible, icon, 10.fixed, label, 1.flexible ].
    /// applyHorizontalSubviewDistribution([ icon, 10.fixed, label ])
    /// ```
    ///
    /// To evenly spread out items:
    /// ```
    /// // This is effectively the same as [ 1.flexible, button1, 1.flexible, button2, 1.flexible, button3 ].
    /// applyHorizontalSubviewDistribution([ button1, button2, button3 ])
    /// ```
    ///
    /// To stack two elements with 50% more space after than before:
    /// ```
    /// applyHorizontalSubviewDistribution([ 2.flexible, label, 12.fixed, textField, 3.flexible ])
    /// ```
    ///
    /// To arrange a pair of buttons on the left and right edges of a view, with a label centered between them:
    /// ```
    /// applyHorizontalSubviewDistribution(
    ///     [ 8.fixed, backButton, 1.flexible, titleLabel, 1.flexible, nextButton, 8.fixed ]
    /// )
    /// ```
    ///
    /// To arrange UI in a view with an interior margin:
    /// ```
    /// applyHorizontalSubviewDistribution([ icon, 10.fixed, label ], inRect: bounds.insetBy(dx: 20, dy: 40))
    /// ```
    ///
    /// To arrange UI horizontally aligned by their top edge 10 pt in from the top edge of their superview:
    /// ```
    /// applyHorizontalSubviewDistribution([ icon, 1.flexible, button ], orthogonalOffset: .top(inset: 10))
    /// ```
    ///
    /// To arrange UI horizontally without simultaneously centering it vertically (the `icon` would need independent
    /// vertical positioning):
    /// ```
    /// applyHorizontalSubviewDistribution([ 1.flexible, icon, 2.flexible ], orthogonalOffset: nil)
    /// ```
    ///
    /// - precondition: All views in the `distribution` must be subviews of the receiver.
    /// - precondition: The `distribution` must not include any given view more than once.
    ///
    /// - parameter distribution: An array of distribution specifiers, ordered from the leading edge to the trailing
    /// edge.
    /// - parameter layoutBounds: The region in the receiver in which to distribute the view in the receiver's
    /// coordinate space. Specify `nil` to use the receiver's bounds. Defaults to `nil`.
    /// - parameter orthogonalAlignment: The vertical alignment to apply to the views. If `nil`, views are left in
    /// their vertical position prior to the distribution. Defaults to centered with no offset.
    public func applyHorizontalSubviewDistribution(
        _ distribution: [ViewDistributionSpecifying],
        inRect layoutBounds: CGRect? = nil,
        orthogonalAlignment: VerticalDistributionAlignment? = .centered(offset: 0)
    ) {
        applySubviewDistribution(distribution, axis: .horizontal, inRect: layoutBounds) { frame, layoutBounds in
            guard let verticalAlignment = orthogonalAlignment else {
                return
            }

            switch verticalAlignment {
            case .top(inset: let inset):
                frame.origin.y = (layoutBounds.minY + inset).roundedToPixel(in: self)
            case .centered(offset: let offset):
                frame.origin.y = (layoutBounds.midY - frame.height / 2 + offset).roundedToPixel(in: self)
            case .bottom(inset: let inset):
                frame.origin.y = (layoutBounds.maxY - (frame.height + inset)).roundedToPixel(in: self)
            }
        }
    }

    // MARK: - Private Methods

    private func applySubviewDistribution(
        _ distribution: [ViewDistributionSpecifying],
        axis: ViewDistributionAxis,
        inRect layoutBounds: CGRect?,
        applyOrthogonalAlignment: (_ subviewFrame: inout CGRect, _ layoutBounds: CGRect) -> Void
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
        var leadingEdgePosition = axis.leadingEdge(of: layoutBounds, layoutDirection: receiverLayoutDirection)
        for item in items {
            switch item {
            case .view(let subview, let insets):
                var frame = subview.untransformedFrame

                switch (axis, receiverLayoutDirection) {
                case (.horizontal, .leftToRight):
                    frame.origin.x = (leadingEdgePosition - insets.left).roundedToPixel(in: self)
                case (.horizontal, .rightToLeft):
                    frame.origin.x = (leadingEdgePosition + insets.right - frame.width).roundedToPixel(in: self)
                case (.vertical, _):
                    frame.origin.y = (leadingEdgePosition - insets.top).roundedToPixel(in: self)
                @unknown default:
                    fatalError("Unknown user interface layout direction")
                }

                applyOrthogonalAlignment(&frame, layoutBounds)

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
                leadingEdgePosition += distanceToMoveOrigin
            case (.horizontal, .rightToLeft):
                leadingEdgePosition -= distanceToMoveOrigin
            @unknown default:
                fatalError("Unknown user interface layout direction")
            }
        }
    }

}
