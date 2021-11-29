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

/// A direction for subview distribution.
internal enum ViewDistributionAxis {

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
