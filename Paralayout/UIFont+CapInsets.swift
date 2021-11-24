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

extension UIFont {

    // MARK: - Public Types
    
    /// The insets, in points, from the top of a UILabel to its font's capHeight, and from the font's baseline to the
    /// label's bottom.
    public struct LabelCapInsets {

        // MARK: - Internal Properties
        
        /// The amount of extra space above a font's cap height, as displayed in a UILabel.
        var top: CGFloat
        
        /// The amount of extra space below a font's baseline, as displayed in a UILabel.
        var bottom: CGFloat

        // MARK: - Public Properties
        
        /// The total amount of extra space above and below a font's cap height and baseline, as displayed in a UILabel.
        public var totalInset: CGFloat {
            return top + bottom
        }

        // MARK: - Public Methods
        
        /// Inset a rect by the extra space above and below a font's cap height and baseline, as displayed in a UILabel.
        /// - parameter rect: The rect to inset (typically a UILabel's `bounds` or `frame`).
        /// - returns: A rect that "tightly" encloses the font's cap height.
        public func inset(rect: CGRect) -> CGRect {
            return CGRect(x: rect.minX, y: rect.minY + top, width: rect.width, height: rect.height - totalInset)
        }
        
        /// Inset a size's height by the extra space above and below a font's cap height and baseline, as displayed in a
        /// UILabel.
        /// - parameter size: The size to shorten (typically a UILabel's height).
        /// - returns: A size reduced in height by the `totalInset`.
        public func inset(size: CGSize) -> CGSize {
            return CGSize(width: size.width, height: size.height - totalInset)
        }

    }

    // MARK: - Public Methods

    /// The space above and below the receiver's capHeight and baseline, as displayed in a UILabel.
    /// - parameter scaleFactor: The UI scale factor for pixel rounding.
    /// - returns: The insets.
    public func labelCapInsets(in scaleFactor: ScaleFactorProviding) -> LabelCapInsets {
        // One would expect ceil(ascender) - floor(descender) so that the baseline would land on a pixel boundary, but
        // sadly no--this is what `UILabel.sizeToFit()` does.
        let lineHeight = (ascender - descender).ceiledToPixel(in: scaleFactor)
        
        // Based on experiments with SFUIText and Helvetica Neue, this is how the text is positioned within a label.
        let bottomInset = lineHeight - ascender.roundedToPixel(in: scaleFactor)
        let topInset = lineHeight - (bottomInset + capHeight.roundedToPixel(in: scaleFactor))
        
        return LabelCapInsets(top: topInset, bottom: bottomInset)
    }
    
}
