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

/// Describes an object that can participate in alignment. In practice, this represents a view.
public protocol Alignable {

    var viewForAlignment: UIView { get }

    var alignmentBounds: CGRect { get }

}

// MARK: -

// The standard object for alignment is a `UIView`. Here we provide a trivial conformance that should be used in the
// majority of cases.

extension UIView: Alignable {

    public var viewForAlignment: UIView {
        return self
    }

    public var alignmentBounds: CGRect {
        return bounds
    }

}
