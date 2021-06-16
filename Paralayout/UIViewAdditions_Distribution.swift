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

    /// The horizontal direction, meaning views will be distributed left-to-right.
    case horizontal

    /// The vertical direction, meaning views will be distributed top-to-bottom.
    case vertical

    // MARK: - Private Methods
    
    fileprivate func select<T>(horizontal: @autoclosure () -> T, vertical: @autoclosure () -> T) -> T {
        switch self {
        case .horizontal:
            return horizontal()
        case .vertical:
            return vertical()
        }
    }
    
    fileprivate func amount(of insets: UIEdgeInsets) -> CGFloat {
        return select(horizontal: insets.horizontalAmount, vertical: insets.verticalAmount)
    }
    
    fileprivate func size(of rect: CGRect) -> CGFloat {
        return select(horizontal: rect.width, vertical: rect.height)
    }
    
    fileprivate func leadingEdge(of rect: CGRect) -> CGFloat {
        return select(horizontal: rect.minX, vertical: rect.minY)
    }
    
    fileprivate func trailingEdge(of rect: CGRect) -> CGFloat {
        return select(horizontal: rect.maxX, vertical: rect.maxY)
    }
    
    fileprivate func setSize(_ size: CGFloat, ofRect rect: inout CGRect) {
        switch self {
        case .horizontal:
            rect.size.width = size
        case .vertical:
            rect.size.height = size
        }
    }
    
    fileprivate func setLeadingEdge(_ leadingEdge: CGFloat, ofRect rect: inout CGRect) {
        switch self {
        case .horizontal:
            rect.origin.x = leadingEdge
        case .vertical:
            rect.origin.y = leadingEdge
        }
    }
    
}

/// Orthogonal alignment options for view distribution.
public enum ViewDistributionAlignment {

    /// Align to the left (for vertical distribution) or top (for horizontal).
    case leading(inset: CGFloat)

    /// Center-align along the distribution axis.
    case centered(offset: CGFloat)

    /// Align to the right (for vertical distribution) or bottom (for horizontal).
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
            if view.superview == nil || view.isHidden || view.alpha == 0 || view.frame.isEmpty {
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
    ) -> (items: [ViewDistributionItem], totalFixedSpace: CGFloat, flexibleSpaceDenominator: CGFloat)
    {
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
            return axis.size(of: view.frame) - axis.amount(of: insets)
            
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
    /// - parameter distribution: An array of distribution specifiers: either a UIView, or a number as `.fixed` or
    /// `.flexible`.
    /// - parameter axis: The direction of layout (optional, defaults to `.vertical`).
    /// - parameter layoutBounds: The region in the view for the layout, or `nil` to indicate the view's bounds
    /// (optional, defaults to `nil`).
    /// - parameter orthogonalAlignment: The alignment (orthogonal to the distribution axis) to apply to the views
    /// (optional, defaults to `.centered`). If `nil`, views are not moved orthogonally.
    ///
    /// - precondition: All views in the `distribution` must be subviews of the receiver.
    /// - precondition: The `distribution` must not include any given view more than once.
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
        
        // Okay, ready to go!
        var viewOrigin = axis.leadingEdge(of: layoutBounds)
        for item in items {
            switch item {
            case .view(let subview, let insets):
                var frame = subview.frame
                
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
                        switch horizontalAlignment {
                        case .leading(inset: let inset):
                            frame.origin.x = (layoutBounds.minX + inset).roundedToPixel(in: self)
                        case .centered(offset: let offset):
                            frame.origin.x = (layoutBounds.midX - frame.width / 2 + offset).roundedToPixel(in: self)
                        case .trailing(inset: let inset):
                            frame.origin.x = (layoutBounds.maxX - (frame.width + inset)).roundedToPixel(in: self)
                        }
                    }
                }
                
                subview.frame = frame
                
            case .fixed, .flexible:
                break
            }
            
            if item.isFlexible {
                // Note that we don't round/floor here, but rather when setting the position of each subview
                // individually, so that rounding error is not accumulated.
                viewOrigin += item.layoutSize(along: axis, multiplier: flexibleSpaceMultiplier)
                
            } else {
                viewOrigin += item.layoutSize(along: axis)
            }
        }
    }
    
    /// Size and position subviews to equally take up all horizontal space.
    ///
    /// - parameter subviews: The subviews to lay out.
    /// - parameter axis: The direction of layout.
    /// - parameter margin: The space between each subview.
    /// - parameter bounds: A custom area within which to layout the subviews, or `nil` to use the receiver's `bounds`
    /// (optional, defaults to `nil`).
    /// - parameter sizeToBounds: If `true`, also set the size of the subviews orthogonal to `axis` to match the size of
    /// the `bounds` (optional, defaults to `false`).
    ///
    /// - precondition: The available space on the specified `axis` of the receiver must be at least as large as the
    /// space required for the specified `margin` between each subview. In other words, the `subviews` may result in a
    /// size of zero along the specified `axis`, but it may not be negative.
    public func spreadOutSubviews(
        _ subviews: [UIView],
        axis: ViewDistributionAxis = .horizontal,
        margin: CGFloat,
        inRect bounds: CGRect? = nil,
        sizeToBounds: Bool = false
    ) {
        let subviewsCount = subviews.count
        guard subviewsCount > 0 else {
            return
        }
        
        // Get some metrics and bail if there isn't enough room for the subviews.
        let subviewBounds = bounds ?? self.bounds
        let totalMarginSpace = margin * CGFloat(subviewsCount - 1)
        let totalSubviewSpace = axis.size(of: subviewBounds) - totalMarginSpace
        
        guard totalSubviewSpace >= 0 else {
            fatalError(
                "Cannot arrange \(subviewsCount) subviews with \(margin)-pt margins in \(subviewBounds.width) points "
                    + "of space!"
            )
        }
        
        var unroundedFrame = subviewBounds
        axis.setSize(totalSubviewSpace / CGFloat(subviewsCount), ofRect: &unroundedFrame)
        
        for subview in subviews {
            let subviewTrailingEdge: CGFloat
            if subview == subviews.last {
                // Make sure the last subview precisely lands on the far edge.
                subviewTrailingEdge = axis.trailingEdge(of: subviewBounds)
            } else {
                // Compute the trailing edge of the *unrounded* frame, not the size, to avoid accumulation of rounding
                // error.
                subviewTrailingEdge = axis.trailingEdge(of: unroundedFrame).roundedToPixel(in: subview)
            }
            
            var subviewFrame = unroundedFrame
            switch axis {
            case .horizontal:
                subviewFrame.size.width = subviewTrailingEdge - axis.leadingEdge(of: subviewFrame)
                if sizeToBounds {
                    subviewFrame.size.height = subviewBounds.height
                }
                
            case .vertical:
                subviewFrame.size.height = subviewTrailingEdge - axis.leadingEdge(of: subviewFrame)
                if sizeToBounds {
                    subviewFrame.size.width = subviewBounds.width
                }
            }
            
            subview.frame = subviewFrame
            
            axis.setLeadingEdge(axis.trailingEdge(of: subviewFrame), ofRect: &unroundedFrame)
        }
        
    }
    
}
