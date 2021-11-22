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

    /// A distribution item for the label that is inset by the label's current font's cap insets.
    public var distributionItemUsingCapInsets: ViewDistributionItem {
        let capInsets = font.labelCapInsets(in: self)
        return .view(self, UIEdgeInsets(top: capInsets.top, left: 0, bottom: capInsets.bottom, right: 0))
    }

}
