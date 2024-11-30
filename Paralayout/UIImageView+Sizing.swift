//
//  Copyright © 2024 Block, Inc.
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

extension UIImageView {

    /// Returns the largest size that will fit within the specified available `sizeToFit`, preserving the receiver's `image`'s aspect ratio.
    ///
    /// If `allowUpscaling` is true, the returned size will be at most the image's native size. This is most commonly used when the `image` is a raster image and is not meant to be scaled up.
    public func sizeThatFitsPreservingAspectRatio(_ sizeToFit: CGSize, allowingUpscaling: Bool) -> CGSize {
        guard let image else {
            return .zero
        }

        if !allowingUpscaling, image.size.width <= sizeToFit.width, image.size.height <= sizeToFit.height {
            return image.size
        } else {
            return image.size.aspectRatio.size(toFit: sizeToFit, in: self)
        }
    }

    /// Returns the largest size that will fit within the specified available `width` and `height`, preserving the receiver's `image`'s aspect ratio.
    ///
    /// If `allowUpscaling` is true, the returned size will be at most the image's native size. This is most commonly used when the `image` is a raster image and is not meant to be scaled up.
    public func sizeThatFitsPreservingAspectRatio(width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, allowingUpscaling: Bool) -> CGSize {
        sizeThatFitsPreservingAspectRatio(CGSize(width: width, height: height), allowingUpscaling: allowingUpscaling)
    }

    /// Sets the size of the receiver's `bounds` such that it will fit within the specified available `sizeToFit`, preserving the receiver's `image`'s aspect ratio.
    ///
    /// If `allowUpscaling` is true, the resulting size will be at most the image's native size. This is most commonly used when the `image` is a raster image and is not meant to be scaled up.
    public func sizeToFitPreservingAspectRatio(_ sizeToFit: CGSize, allowingUpscaling: Bool) {
        bounds.size = sizeThatFitsPreservingAspectRatio(sizeToFit, allowingUpscaling: allowingUpscaling)
    }

    /// Sets the size of the receiver's `bounds` such that it will fit within the specified available `width` and `height`, preserving the receiver's `image`'s aspect ratio.
    ///
    /// If `allowUpscaling` is true, the resulting size will be at most the image's native size. This is most commonly used when the `image` is a raster image and is not meant to be scaled up.
    public func sizeToFitPreservingAspectRatio(width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, allowingUpscaling: Bool) {
        sizeToFitPreservingAspectRatio(CGSize(width: width, height: height), allowingUpscaling: allowingUpscaling)
    }

}
