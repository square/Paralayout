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

/// A means of getting a `SubviewDistributionItem`: either a UIView, or a number as `.fixed` or `.flexible`.
public protocol ViewDistributionSpecifying {

    var distributionItem: ViewDistributionItem { get }

}

// MARK: -

/// A direction for subview distribution.
public enum ViewDistributionAxis {

    /// The horizontal direction, meaning views will be distributed left-to-right or right-to-left.
    case horizontal

    /// The vertical direction, meaning views will be distributed top-to-bottom.
    case vertical

    // MARK: - Private Methods

    fileprivate func amount(of insets: UIEdgeInsets) -> CGFloat {
        switch self {
        case .horizontal:
            return insets.horizontalAmount
        case .vertical:
            return insets.verticalAmount
        }
    }

    fileprivate func size(of rect: CGRect) -> CGFloat {
        switch self {
        case .horizontal:
            return rect.width
        case .vertical:
            return rect.height
        }
    }

    fileprivate func leadingEdge(of rect: CGRect, layoutDirection: UIUserInterfaceLayoutDirection) -> CGFloat {
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

    fileprivate func trailingEdge(
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

    fileprivate func setSize(_ size: CGFloat, ofRect rect: inout CGRect) {
        switch self {
        case .horizontal:
            rect.size.width = size
        case .vertical:
            rect.size.height = size
        }
    }

    fileprivate func setLeadingEdge(
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

/// An element of a horizontal or vertical distribution.
public enum ViewDistributionItem: ViewDistributionSpecifying {

    /// A UIView, with adjustments to how much space it should take up.
    case view(UIView, UIEdgeInsets)

    /// A constant spacer between two other elements.
    case fixed(CGFloat)

    /// Proportional spacer, a fraction of the space not taken up by UIViews or fixed spacers.
    case flexible(CGFloat)

    // MARK: - Public Static Methods

    /// Filter invisible views (nil, uninstalled, hidden, or transparent) from a distribution, and collapse adjacent
    /// spacers (preferring larger ones).
    /// - parameter distribution: An array of optional distribution specifiers: either a UIView, or a number as `.fixed`
    /// or `.flexible`.
    /// - returns: An array of DistributionItems, without any invisible views, or sequential `.fixed` or `.flexible`
    /// spacers.
    public static func collapsing(_ distribution: [ViewDistributionSpecifying?]) -> [ViewDistributionItem] {
        var collapsedItems = [ViewDistributionItem]()

        func isViewVisible(_ view: UIView) -> Bool {
            if view.superview == nil || view.isHidden || view.alpha == 0 {
                return false

            } else if let label = view as? UILabel {
                if let text = label.text {
                    return !text.isEmpty
                } else {
                    return false
                }

            } else if let imageView = view as? UIImageView {
                return (imageView.image != nil)

            } else {
                return true
            }
        }

        for distributionSpecifier in distribution {
            // Filter out anything that's nil.
            guard let item = distributionSpecifier?.distributionItem else {
                continue
            }

            switch item {
            case .view(let view, _):
                // Filter out invisible views.
                if isViewVisible(view) {
                    collapsedItems.append(item)
                }

            case .fixed(let fixedSpace):
                if let previousItem = collapsedItems.last {
                    switch previousItem {
                    case .view:
                        // Space after a visible view: append.
                        collapsedItems.append(item)

                    case .fixed(let previousFixedSpace):
                        // Fixed after fixed: replace if larger.
                        if fixedSpace > previousFixedSpace {
                            collapsedItems.removeLast()
                            collapsedItems.append(item)
                        }

                    case .flexible:
                        // Fixed after flexible: skip.
                        break
                    }

                } else {
                    // This is the first item: append.
                    collapsedItems.append(item)
                }

            case .flexible(let flexibleSpace):
                if let previousItem = collapsedItems.last {
                    switch previousItem {
                    case .view:
                        // Space after a visible view: append.
                        collapsedItems.append(item)

                    case .fixed:
                        // Flexible after fixed: replace.
                        collapsedItems.removeLast()
                        collapsedItems.append(item)

                    case .flexible(let previousFlexibleSpace):
                        // Flexible after flexible: replace if larger.
                        if flexibleSpace > previousFlexibleSpace {
                            collapsedItems.removeLast()
                            collapsedItems.append(item)
                        }
                    }

                } else {
                    // This is the first item: append.
                    collapsedItems.append(item)
                }
            }
        }

        // Trim out fixed space at the start or finish.
        if let firstItem = collapsedItems.first {
            switch firstItem {
            case .fixed:
                collapsedItems.removeFirst()
            case .flexible, .view:
                break
            }
        }

        if let lastItem = collapsedItems.last {
            switch lastItem {
            case .fixed:
                collapsedItems.removeLast()
            case .flexible, .view:
                break
            }
        }

        // All set.
        return collapsedItems
    }

    /// Filter invisible views (nil, uninstalled, hidden, or transparent) from a distribution, and collapse adjacent
    /// spacers (preferring larger ones).
    /// - parameter distribution: An series of optional distribution specifiers: either a UIView, or a number as
    /// `.fixed` or `.flexible`.
    /// - returns: An array of DistributionItems, without any invisible views, or sequential `.fixed` or `.flexible`
    /// spacers.
    public static func collapsing(_ distribution: ViewDistributionSpecifying? ...) -> [ViewDistributionItem] {
        return collapsing(distribution)
    }

    // MARK: - Properties

    /// Itself: `DistributionItem` trivially conforms to `ViewDistributionSpecifying`.
    public var distributionItem: ViewDistributionItem {
        return self
    }

    /// Whether or not this item is flexible.
    public var isFlexible: Bool {
        switch self {
        case .view, .fixed:
            return false
        case .flexible:
            return true
        }
    }

    // MARK: - Private Methods

    /// Maps the specifiers to their provided items, and adds implied flexible spacers as necessary.
    /// If no spacers are included, equal flexible spacers are inserted between all views; if no `.flexible` spacers are
    /// included, two equal ones are added to the beginning and end.
    /// - returns: An array of DistributionItems suitable for layout and/or measurement, and tallies of all fixed and
    /// flexible space. If the distribution is invalid (no views, any view not a subview of the superview, or any view
    /// repeated in the distribution), returns an empty array.
    fileprivate static func items(
        impliedIn distribution: [ViewDistributionSpecifying],
        axis: ViewDistributionAxis,
        superview: UIView?
    ) -> (items: [ViewDistributionItem], totalFixedSpace: CGFloat, flexibleSpaceDenominator: CGFloat) {
        var distributionItems = [ViewDistributionItem]()
        var totalViewSize: CGFloat = 0
        var totalFixedSpace: CGFloat = 0
        var totalFlexibleSpace: CGFloat = 0

        var subviewsToDistribute = Set<UIView>()

        // Map the specifiers to items, tallying up space along the way.
        for specifier in distribution {
            let item = specifier.distributionItem
            let layoutSize = item.layoutSize(along: axis)

            switch item {
            case .view(let view, _):
                // Validate the view.
                guard superview == nil || view.superview === superview else {
                    fatalError("\(view) is not a subview of \(String(describing: superview))!")
                }

                guard !subviewsToDistribute.contains(view) else {
                    fatalError("\(view) is included twice in \(distribution)!")
                }

                subviewsToDistribute.insert(view)

                totalViewSize += layoutSize

            case .fixed:
                totalFixedSpace += layoutSize

            case .flexible:
                totalFlexibleSpace += layoutSize
            }

            distributionItems.append(item)
        }

        // Exit early if no subviews were provided.
        guard subviewsToDistribute.count > 0 else {
            return ([], 0, 0)
        }

        // Insert flexible space if necessary.
        if totalFlexibleSpace == 0 {
            if totalFixedSpace == 0 {
                // No spacers at all: insert `1.flexible` between all items.
                for i in 0 ..< (distributionItems.count + 1) {
                    distributionItems.insert(1.flexible, at: i * 2)
                    totalFlexibleSpace += 1
                }
            } else {
                // Only fixed spacers: add `1.flexible` on both ends.
                distributionItems.insert(1.flexible, at: 0)
                distributionItems.append(1.flexible)
                totalFlexibleSpace += 2
            }
        }

        return (distributionItems, totalFixedSpace + totalViewSize, totalFlexibleSpace)
    }

    /// Returns the length of the DistributionItem (`axis` and `multiplier` are relevant only for `.view` and
    /// `.flexible` items, respectively).
    fileprivate func layoutSize(along axis: ViewDistributionAxis, multiplier: CGFloat = 1) -> CGFloat {
        switch self {
        case .view(let view, let insets):
            return axis.size(of: view.untransformedFrame) - axis.amount(of: insets)

        case .fixed(let margin):
            return margin

        case .flexible(let space):
            return space * multiplier
        }
    }

}

// MARK: -

extension CGFloat {

    /// Use the value as a fixed spacer in a distribution.
    public var fixed: ViewDistributionItem {
        return .fixed(self)
    }

    /// Use the value as a flexible (proportional) spacer in a distribution.
    public var flexible: ViewDistributionItem {
        return .flexible(self)
    }

}

extension Double {

    /// Use the value as a fixed spacer in a distribution.
    public var fixed: ViewDistributionItem {
        return .fixed(CGFloat(self))
    }

    /// Use the value as a flexible (proportional) spacer in a distribution.
    public var flexible: ViewDistributionItem {
        return .flexible(CGFloat(self))
    }

}

extension Int {

    /// Use the value as a fixed spacer in a distribution.
    public var fixed: ViewDistributionItem {
        return .fixed(CGFloat(self))
    }

    /// Use the value as a flexible (proportional) spacer in a distribution.
    public var flexible: ViewDistributionItem {
        return .flexible(CGFloat(self))
    }

}

extension UIView : ViewDistributionSpecifying {

    /// Adopt `ViewDistributionSpecifying`, making it possible to include UIView instances directly in distributions
    /// passed to `apply[Vertical,Horizontal]Distribution()`.
    public var distributionItem: ViewDistributionItem {
        return .view(self, .zero)
    }

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
