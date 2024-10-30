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

import os
import UIKit

public enum TargetAlignmentBehavior {

    /// Align to the position in the target view's bounds, ignoring any origin offset. This is most commonly used
    /// when aligning sibling views in a hierarchy.
    case untransformedFrame

    /// Align to the position in the target view's bounds, including any origin offset. This is most commonly used
    /// when aligning a view to a view in its superview chain.
    case bounds

    /// Align views based on their relationship in the view hierarchy. If the target view is in the superview chain
    /// of the view being aligned, this will align to the target view's untransformed bounds. Otherwise it will
    /// align to the target view's untransformed frame.
    case automatic

}

extension Alignable {

    // MARK: - View Alignment - Core

    /// Calculates the offset between two views' positions, ignoring any transforms in the view hierarchy.
    ///
    /// - precondition: The receiver and `otherView` must be in the same view hierarchy.
    ///
    /// - parameter position: The position in the receiving view's untransformed frame.
    /// - parameter otherView: The other view for the measurement.
    /// - parameter otherPosition: The position in the `otherView`'s untransformed frame to use for the measurement.
    /// - returns: The offset from the receiver's `position` to the `otherView`'s `otherPosition`.
    public func untransformedFrameOffset(
        from position: Position,
        to otherView: Alignable,
        _ otherPosition: Position,
        alignmentBehavior: TargetAlignmentBehavior = .automatic
    ) throws -> UIOffset {
        let receiverContext = alignmentContext
        let receiverView = receiverContext.view

        let targetContext = otherView.alignmentContext
        let targetView = targetContext.view

        // We can't be aligned to another view if we don't have a superview.
        guard let superview = receiverContext.view.superview else {
            ParalayoutAlertForInvalidViewHierarchy()
            return .zero
        }

        switch position {
        case .topLeft, .topRight, .leftCenter, .rightCenter, .bottomLeft, .bottomRight:
            switch otherPosition {
            case .topLeading, .topTrailing, .leadingCenter, .trailingCenter, .bottomLeading, .bottomTrailing:
                ParalayoutAlertForMismatchedAlignmentPositionTypes()
            default:
                break
            }

        case .topLeading, .topTrailing, .leadingCenter, .trailingCenter, .bottomLeading, .bottomTrailing:
            switch otherPosition {
            case .topLeft, .topRight, .leftCenter, .rightCenter, .bottomLeft, .bottomRight:
                ParalayoutAlertForMismatchedAlignmentPositionTypes()
            default:
                break
            }

        default:
            break
        }

        let sourcePoint = try superview.untransformedConvert(
            receiverContext.pointInBounds(at: position),
            from: receiverView
        )
        let targetIsInSourceSuperviewChain = sequence(first: receiverView, next: { $0.superview }).contains(targetView)

        let targetPoint: CGPoint
        switch alignmentBehavior {
        case .bounds,
             .automatic where targetIsInSourceSuperviewChain:
            targetPoint = try superview.untransformedConvert(
                targetContext
                    .pointInBounds(at: otherPosition)
                    .offset(
                        by: UIOffset(horizontal: -targetView.bounds.origin.x, vertical: -targetView.bounds.origin.y)
                    ),
                from: targetView
            )

        case .untransformedFrame,
             .automatic /* where !targetIsInSourceSuperviewChain */:
            targetPoint = try superview.untransformedConvert(
                targetContext.pointInBounds(at: otherPosition),
                from: targetView
            )
        }

        return sourcePoint.offset(to: targetPoint)
    }

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
    /// - parameter offset: An additional offset to apply to the alignment, e.g. to leave a space between the two views.
    public func align(
        _ position: Position,
        with otherView: Alignable,
        _ otherPosition: Position,
        alignmentBehavior: TargetAlignmentBehavior = .automatic,
        offset: UIOffset
    ) {
        do {
            let receiverView = alignmentContext.view
            receiverView.untransformedFrame.origin = receiverView.untransformedFrame.origin
                .offset(
                    by: try untransformedFrameOffset(
                        from: position,
                        to: otherView,
                        otherPosition,
                        alignmentBehavior: alignmentBehavior
                    )
                )
                .offset(by: offset)
                .roundedToPixel(in: receiverView)

        } catch {
            ParalayoutAlertForInvalidViewHierarchy()
        }
    }

}

// MARK: -

extension AlignmentContext {

    /// The location of a position in the view in the view's `bounds`.
    ///
    /// - parameter position: The position to use.
    /// - returns: The point at the specified position.
    fileprivate func pointInBounds(at position: Position) -> CGPoint {
        return position.point(in: alignmentBounds, layoutDirection: view.effectiveUserInterfaceLayoutDirection)
    }

}

// MARK: -


/// Triggered when an alignment method is called that uses mismatched position types, i.e. aligning a view's leading or
/// trailing edge to another view's left or right edge, or vice versa. This type of mismatch is likely to look correct
/// under certain circumstance, but may look incorrect when using a different user interface layout direction.
@MainActor
private func ParalayoutAlertForMismatchedAlignmentPositionTypes() {
    os_log(
        "%@",
        log: ParalayoutLog,
        type: .default,
        """
        Paralayout detected an alignment with mismatched position types. Set a symbolic breakpoint for \
        \"ParalayoutAlertForMismatchedAlignmentPositions\" to debug. Call stack:
        \(Thread.callStackSymbols.dropFirst(2).joined(separator: "\n"))
        """
    )
}

/// Triggered when an alignment method is called that involves two views that are not installed in the same view
/// hierarchy. The behavior of aligning two views not in the same view hierarchy is undefined.
@MainActor
private func ParalayoutAlertForInvalidViewHierarchy() {
    os_log(
        "%@",
        log: ParalayoutLog,
        type: .default,
        """
        Paralayout detected an alignment with an invalid view hierarchy. The views involved in alignment calls must \
        be in the same view hierarchy. Set a symbolic breakpoint for \"ParalayoutAlertForInvalidViewHierarchy\" to \
        debug. Call stack:
        \(Thread.callStackSymbols.dropFirst(1).joined(separator: "\n"))
        """
    )
}
