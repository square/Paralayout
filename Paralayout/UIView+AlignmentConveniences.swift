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

extension UIView {

    /// Move the view to align it with another view.
    ///
    /// - precondition: The receiver and the `otherView` must be in the same view hierarchy.
    ///
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter otherView: The view to which the receiving view will be aligned.
    /// - parameter otherPosition: The position within `otherView` to use for alignment.
    /// - parameter alignmentBehavior: Controls how the point at the `otherPosition` in the `otherView` should be
    /// calculated. Defaults to `.automatic`, which will align the views in the most common way based on their
    /// relationship in the view hierarchy.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        with otherView: UIView,
        _ otherPosition: Position,
        alignmentBehavior: TargetAlignmentBehavior = .automatic,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        align(
            position,
            with: otherView,
            otherPosition,
            alignmentBehavior: alignmentBehavior,
            offset: UIOffset(horizontal: horizontalOffset, vertical: verticalOffset)
        )
    }

    /// Move the view to align it within its superview, based on position.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter superviewPosition: The position within the view's `superview` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        withSuperviewPosition superviewPosition: Position,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        guard let superview = superview else {
            fatalError("Can't align view without a superview!")
        }

        align(
            position,
            with: superview,
            superviewPosition,
            offset: .init(horizontal: horizontalOffset, vertical: verticalOffset)
        )
    }

    /// Move the view to align it within its superview, based on position.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter superviewPosition: The position within the view's `superview` to use for alignment.
    /// - parameter offset: An additional offset to apply to the alignment.
    public func align(
        _ position: Position,
        withSuperviewPosition superviewPosition: Position,
        offset: UIOffset
    ) {
        guard let superview = superview else {
            fatalError("Can't align view without a superview!")
        }

        align(
            position,
            with: superview,
            superviewPosition,
            offset: offset
        )
    }

    /// Move the view to align it within its superview, based on coordinate.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position within the receiving view to use for alignment.
    /// - parameter superviewPoint: The coordinate within the view's `superview` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the alignment (defaults to 0).
    /// - parameter verticalOffset: An additional vertical offset to apply to the alignment (defaults to 0).
    public func align(
        _ position: Position,
        withSuperviewPoint superviewPoint: CGPoint,
        horizontalOffset: CGFloat = 0,
        verticalOffset: CGFloat = 0
    ) {
        guard let superview = superview else {
            fatalError("Can't align view without a superview!")
        }

        // Resolve the position before aligning, since we always want to use the top left corner (i.e. the origin) of
        // superview, regardless of the layout direction. Without this, we'll hit the mismatched alignment positions
        // alert when using a leading/trailing position.
        let resolvedPosition = ResolvedPosition(resolving: position, with: effectiveUserInterfaceLayoutDirection)

        align(
            resolvedPosition.layoutDirectionAgnosticPosition,
            with: superview,
            .topLeft,
            offset: .init(horizontal: superviewPoint.x + horizontalOffset, vertical: superviewPoint.x + verticalOffset)
        )
    }

    /// Move the view to align it within its superview.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position in both the receiving view and its `superview` to use for alignment.
    /// - parameter horizontalOffset: An additional horizontal offset to apply to the receiver. Defaults to no offset.
    /// - parameter verticalOffset: An additional vertical offset to apply to the receiver. Defaults to no offset.
    public func alignToSuperview(_ position: Position, horizontalOffset: CGFloat = 0, verticalOffset: CGFloat = 0) {
        align(
            position,
            withSuperviewPosition: position,
            horizontalOffset: horizontalOffset,
            verticalOffset: verticalOffset
        )
    }

    /// Move the view to align it within its superview.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position in both the receiving view and its `superview` to use for alignment.
    /// - parameter offset: An additional offset to apply to the receiver.
    public func alignToSuperview(_ position: Position, offset: UIOffset) {
        align(
            position,
            withSuperviewPosition: position,
            offset: offset
        )
    }

    /// Move the view to align it within its superview.
    ///
    /// - precondition: The receiver must have a superview.
    ///
    /// - parameter position: The position in both the receiving view and its `superview` to use for alignment.
    /// - parameter inset: An inset (horizontal, vertical, or diagonal based on the position) to apply. An inset on
    /// `.center` is interpreted as a vertical offset away from the top.
    public func alignToSuperview(_ position: Position, inset: CGFloat) {
        guard let superview = self.superview else {
            fatalError("Can't align view without a superview!")
        }

        let offset: UIOffset
        switch ResolvedPosition(resolving: position, with: effectiveUserInterfaceLayoutDirection) {
        case .topLeft:
            offset = UIOffset(horizontal: inset,    vertical: inset)
        case .topCenter:
            offset = UIOffset(horizontal: 0,        vertical: inset)
        case .topRight:
            offset = UIOffset(horizontal: -inset,   vertical: inset)
        case .leftCenter:
            offset = UIOffset(horizontal: inset,    vertical: 0)
        case .center:
            offset = UIOffset(horizontal: 0,        vertical: inset)
        case .rightCenter:
            offset = UIOffset(horizontal: -inset,   vertical: 0)
        case .bottomLeft:
            offset = UIOffset(horizontal: inset,    vertical: -inset)
        case .bottomCenter:
            offset = UIOffset(horizontal: 0,        vertical: -inset)
        case .bottomRight:
            offset = UIOffset(horizontal: -inset,   vertical: -inset)
        }

        self.align(position, with: superview, position, offset: offset)
    }

}
