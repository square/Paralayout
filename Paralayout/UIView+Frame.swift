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

    // MARK: - Public Properties

    /// A rect representing the view's `frame` (the rect representing its size and location in its superview's
    /// coordinate space) as though the `transform3D` were always the identity transform.
    ///
    /// This rect is always well-defined, regardless of any transform that has been applied to the view, and so is safe
    /// to use even when `frame` is not.
    public var untransformedFrame: CGRect {
        get {
            return CGRect(
                origin: CGPoint(
                    x: layer.position.x - bounds.size.width * layer.anchorPoint.x,
                    y: layer.position.y - bounds.size.height * layer.anchorPoint.y
                ),
                size: bounds.size
            )
        }
        set {
            bounds.size = newValue.size
            center = CGPoint(
                x: newValue.minX + newValue.width * layer.anchorPoint.x,
                y: newValue.minY + newValue.height * layer.anchorPoint.y
            )
        }
    }

    // MARK: - Internal Methods

    /// Converts a point from the coordinate system of a given view to that of the receiver, ignoring any non-identity
    /// transforms in the view hierarchy.
    ///
    /// - complexity: O(*n* + *m*), where *n* is the depth of the receiver in the view hierarchy and *m* is the depth of
    /// the `sourceView` in the view hierarchy.
    func untransformedConvert(_ point: CGPoint, from sourceView: UIView) throws -> CGPoint {
        enum Error: Swift.Error {
            case noCommonAncestor
        }

        let sourceSuperviewChainSet = Set(sequence(first: sourceView, next: { $0.superview }))
        let targetSuperviewChain = sequence(first: self, next: { $0.superview })

        // Find the most recent common ancestor so we have a reference point from which to calculate the origins. If the
        // views don't have a common ancestor (meaning they're not in the same window), there's no way to figure out
        // their relative arrangement.
        guard let commonAncestor = targetSuperviewChain.first(where: { sourceSuperviewChainSet.contains($0) }) else {
            throw Error.noCommonAncestor
        }

        let sourceOriginInCommonAncestor = sourceView.originInCoordinateSpace(of: commonAncestor)
        let targetOriginInCommonAncestor = self.originInCoordinateSpace(of: commonAncestor)

        return CGPoint(
            x: sourceOriginInCommonAncestor.x - targetOriginInCommonAncestor.x + point.x,
            y: sourceOriginInCommonAncestor.y - targetOriginInCommonAncestor.y + point.y
        )
    }

    // MARK: - Private Methods

    private func originInCoordinateSpace(of ancestor: UIView) -> CGPoint {
        let superviewChainToAncestor = sequence(first: self) { previous in
            if previous == ancestor {
                return nil
            }
            return previous.superview
        }

        return superviewChainToAncestor.reduce(.zero) {
            let untransformedSuperviewFrame = $1.untransformedFrame
            let boundsOrigin = $1.bounds.origin
            return CGPoint(
                x: $0.x + untransformedSuperviewFrame.origin.x - boundsOrigin.x,
                y: $0.y + untransformedSuperviewFrame.origin.y - boundsOrigin.y
            )
        }
    }

}
