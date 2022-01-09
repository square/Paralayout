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
