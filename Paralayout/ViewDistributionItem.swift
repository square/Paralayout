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

/// An element of a horizontal or vertical distribution.
public enum ViewDistributionItem: ViewDistributionSpecifying {

    /// A UIView, with adjustments to how much space it should take up.
    case view(UIView, UIEdgeInsets)

    /// A constant spacer between two other elements.
    case fixed(CGFloat)

    /// Proportional spacer, a fraction of the space not taken up by UIViews or fixed spacers.
    case flexible(CGFloat)

    // MARK: - Public Static Methods

    /// Filter invisible views (`nil`, uninstalled, hidden, or transparent) from a distribution, and collapse adjacent
    /// spacers (preferring larger ones).
    ///
    /// - parameter distribution: An array of optional distribution specifiers to be collapsed.
    /// - returns: An array of `DistributionItem`s, without any invisible views or sequential `.fixed` or `.flexible`
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

    // MARK: - Public Properties

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

    // MARK: - Internal Static Methods

    /// Maps the specifiers to their provided items, and adds implied flexible spacers as necessary.
    ///
    /// * If no spacers are included, equal flexible spacers are inserted between all views.
    /// * If no `.flexible` spacers are included, two equal ones are added to the beginning and end.
    ///
    /// - precondition: All views in the `distribution` must be subviews of the `superview`.
    /// - precondition: The `distribution` must not include any given view more than once.
    ///
    /// - returns: An array of `ViewDistributionItem`s suitable for layout and/or measurement, and tallies of all fixed
    /// and flexible space. If the distribution is invalid (no views, any view not a subview of the superview, or any
    /// view repeated in the distribution), returns an empty array.
    internal static func items(
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

    // MARK: - Internal Methods

    /// Returns the length of the DistributionItem (`axis` and `multiplier` are relevant only for `.view` and
    /// `.flexible` items, respectively).
    internal func layoutSize(along axis: ViewDistributionAxis, multiplier: CGFloat = 1) -> CGFloat {
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

/// A means of getting a `ViewDistributionItem`: either a UIView, or a number as `.fixed` or `.flexible`.
public protocol ViewDistributionSpecifying {

    var distributionItem: ViewDistributionItem { get }

}

extension UIView: ViewDistributionSpecifying {

    // Adopt `ViewDistributionSpecifying`, making it possible to include UIView instances directly in distributions
    // passed to `apply{Vertical,Horizontal}SubviewDistribution()`.
    public var distributionItem: ViewDistributionItem {
        return .view(self, .zero)
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
