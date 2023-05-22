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

extension UILabel {

    /// An alignment proxy that supports aligning the label using a rect inset from its `bounds` by its cap insets.
    public var capInsetsAlignmentProxy: Alignable {
        let capInsets = font.labelCapInsets(in: self)
        return InsetAlignmentProxy(
            proxiedView: self,
            insets: UIEdgeInsets(top: capInsets.top, left: 0, bottom: capInsets.bottom, right: 0)
        )
    }

}

// MARK: -

public struct TextRectLayoutProxy: Alignable {

    // MARK: - Life Cycle

    public init(
        proxiedLabel: UILabel,
        limitedToNumberOfLines numberOfLines: Int? = nil,
        insetByCapInsets: Bool = false
    ) {
        self.proxiedLabel = proxiedLabel
        self.numberOfLines = numberOfLines
        self.insetByCapInsets = insetByCapInsets
    }

    // MARK: - Private Properties

    private let proxiedLabel: UILabel

    private let numberOfLines: Int?

    private let insetByCapInsets: Bool

    // MARK: - Alignable

    public var alignmentContext: AlignmentContext {
        var alignmentBounds = proxiedLabel.textRect(
            forBounds: proxiedLabel.bounds,
            limitedToNumberOfLines: numberOfLines ?? proxiedLabel.numberOfLines
        )

        if insetByCapInsets {
            let capInsets = proxiedLabel.font.labelCapInsets(in: proxiedLabel)
            alignmentBounds = capInsets.inset(rect: alignmentBounds)
        }

        return AlignmentContext(
            view: proxiedLabel,
            alignmentBounds: alignmentBounds
        )
    }

}

extension UILabel {

    /// An alignment proxy that supports aligning the label using the text rect of its first line.
    ///
    /// - Note: The text rect doesn't always accurately represent the text at the _end_ of the first line. It's most
    /// accurate when used to align to the text at the _start_ of the first line (where the start of the line depends on
    /// the text alignment).
    public var firstLineAlignmentProxy: Alignable {
        return TextRectLayoutProxy(
            proxiedLabel: self,
            limitedToNumberOfLines: 1,
            insetByCapInsets: false
        )
    }

    /// An alignment proxy that supports aligning the label using the text rect of its first line, inset by its cap
    /// insets.
    ///
    /// - Note: The text rect doesn't always accurately represent the text at the _end_ of the first line. It's most
    /// accurate when used to align to the text at the _start_ of the first line (where the start of the line depends on
    /// the text alignment).
    public var firstLineCapInsetsAlignmentProxy: Alignable {
        return TextRectLayoutProxy(
            proxiedLabel: self,
            limitedToNumberOfLines: 1,
            insetByCapInsets: true
        )
    }

}
