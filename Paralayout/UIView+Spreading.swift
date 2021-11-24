//
//  Copyright © 2021 Square, Inc.
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

/// Orthogonal alignment options for view spreading.
public enum ViewSpreadingBehavior {

    /// Expand the view to fill the available space.
    case fill

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

    /// Size and position subviews to equally take up all horizontal space.
    ///
    /// - precondition: The available space on the specified `axis` of the receiver must be at least as large as the
    /// space required for the specified `margin` between each subview. In other words, the `subviews` may result in a
    /// size of zero along the specified `axis`, but it may not be negative.
    ///
    /// - parameter subviews: The subviews to spread out, ordered from the leading/top edge to the trailing/bottom edge
    /// of the receiver.
    /// - parameter axis: The axis along which to spread the `subviews`.
    /// - parameter margin: The space between each subview.
    /// - parameter bounds: A custom area within which to layout the subviews, or `nil` to use the receiver's `bounds`
    /// (optional, defaults to `nil`).
    /// - parameter sizeToBounds: If `true`, also set the size of the subviews orthogonal to `axis` to match the size of
    /// the `bounds` (optional, defaults to `false`).
    public func spreadOutSubviews(
        _ subviews: [UIView],
        axis: ViewDistributionAxis = .horizontal,
        margin: CGFloat,
        inRect bounds: CGRect? = nil,
        orthogonalBehavior: ViewSpreadingBehavior = .fill
    ) {
        let subviewsCount = subviews.count
        guard subviewsCount > 0 else {
            return
        }

        // Get some metrics and bail if there isn't enough room for the subviews.
        let contentBounds = bounds ?? self.bounds
        let totalMarginSpace = margin * CGFloat(subviewsCount - 1)
        let totalSubviewSpace = axis.size(of: contentBounds) - totalMarginSpace

        guard totalSubviewSpace >= 0 else {
            fatalError(
                "Cannot arrange \(subviewsCount) subviews with \(margin)-pt margins in \(contentBounds.width) points "
                    + "of space!"
            )
        }

        let receiverLayoutDirection = effectiveUserInterfaceLayoutDirection

        // To simplify the logic below, spread the subviews using increasing coordinate values. This means we can treat
        // the rest of the layout as always left-to-right.
        let increasingCoordinateSubviews: [UIView]
        switch (axis, receiverLayoutDirection) {
        case (.vertical, _), (.horizontal, .leftToRight):
            increasingCoordinateSubviews = subviews
        case (.horizontal, .rightToLeft):
            increasingCoordinateSubviews = subviews.reversed()
        @unknown default:
            fatalError("Unknown user interface layout direction")
        }

        var unroundedFrame = contentBounds
        axis.setSize(totalSubviewSpace / CGFloat(subviewsCount), ofRect: &unroundedFrame)

        for subview in increasingCoordinateSubviews {
            let subviewTrailingEdge: CGFloat
            if subview == increasingCoordinateSubviews.last {
                // Make sure the last subview precisely lands on the far edge.
                subviewTrailingEdge = axis.trailingEdge(of: contentBounds, layoutDirection: .leftToRight)

            } else {
                // Compute the trailing edge of the *unrounded* frame, not the size, to avoid accumulation of rounding
                // error.
                subviewTrailingEdge = axis
                    .trailingEdge(of: unroundedFrame, layoutDirection: .leftToRight)
                    .roundedToPixel(in: subview)
            }

            var subviewFrame = unroundedFrame
            switch axis {
            case .horizontal:
                let subviewLeadingEdge = axis.leadingEdge(of: subviewFrame, layoutDirection: .leftToRight)
                subviewFrame.size.width = abs(subviewTrailingEdge - subviewLeadingEdge)

                switch orthogonalBehavior {
                case .fill:
                    // No-op. The `subviewFrame` has already been sized and positioned to fill the available vertical
                    // space in the container.
                    break

                case let .leading(inset):
                    subviewFrame.size.height = subview.bounds.height
                    subviewFrame.origin.y = inset

                case let .centered(offset):
                    subviewFrame.size.height = subview.bounds.height
                    subviewFrame.origin.y = (unroundedFrame.height - subviewFrame.height) / 2 + offset

                case let .trailing(inset):
                    subviewFrame.size.height = subview.bounds.height
                    subviewFrame.origin.y = unroundedFrame.height - subviewFrame.height - inset
                }

            case .vertical:
                let subviewLeadingEdge = axis.leadingEdge(of: subviewFrame, layoutDirection: .leftToRight)
                subviewFrame.size.height = abs(subviewTrailingEdge - subviewLeadingEdge)

                switch (orthogonalBehavior, receiverLayoutDirection) {
                case (.fill, _):
                    // No-op. The `subviewFrame` has already been sized and positioned to fill the available horizontal
                    // space in the container.
                    break

                case let (.leading(inset), .leftToRight),
                     let (.trailing(inset), .rightToLeft):
                    subviewFrame.size.width = subview.bounds.width
                    subviewFrame.origin.x = inset

                case let (.leading(inset), .rightToLeft),
                     let (.trailing(inset), .leftToRight):
                    subviewFrame.size.width = subview.bounds.width
                    subviewFrame.origin.x = unroundedFrame.width - subviewFrame.width - inset

                case let (.centered(offset), .leftToRight):
                    subviewFrame.size.width = subview.bounds.width
                    subviewFrame.origin.x = (unroundedFrame.width - subviewFrame.width) / 2 + offset

                case let (.centered(offset), .rightToLeft):
                    subviewFrame.size.width = subview.bounds.width
                    subviewFrame.origin.x = (unroundedFrame.width - subviewFrame.width) / 2 - offset

                @unknown default:
                    fatalError("Unknown user interface layout direction")
                }
            }

            subview.untransformedFrame = subviewFrame

            axis.setLeadingEdge(
                axis.trailingEdge(of: subviewFrame, layoutDirection: .leftToRight, extendedBy: margin),
                ofRect: &unroundedFrame,
                layoutDirection: .leftToRight
            )
        }

    }

}
