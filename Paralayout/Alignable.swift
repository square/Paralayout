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

    var alignmentContext: AlignmentContext { get }

}

public struct AlignmentContext {

    public var view: UIView

    public var alignmentBounds: CGRect

}

// MARK: -

// The standard object for alignment is a `UIView`. Here we provide a trivial conformance that should be used in the
// majority of cases.

extension UIView: Alignable {

    public var alignmentContext: AlignmentContext {
        return AlignmentContext(view: self, alignmentBounds: bounds)
    }

}

// MARK: -

/// An alignment proxy that supports a view participating in alignment using a rect inset from its `bounds` by the
/// specified `insets`.
public struct InsetAlignmentProxy: Alignable {

    // MARK: - Life Cycle

    public init(proxiedView: UIView, insets: UIEdgeInsets) {
        self.proxiedView = proxiedView
        self.insets = insets
    }

    // MARK: - Public Properties

    public let proxiedView: UIView

    public var insets: UIEdgeInsets

    // MARK: - Alignable

    public var alignmentContext: AlignmentContext {
        return AlignmentContext(
            view: proxiedView,
            alignmentBounds: proxiedView.bounds.inset(by: insets)
        )
    }

}

extension UIView {

    /// An alignment proxy that supports the view participating in alignment using the rect inset from its `bounds` by
    /// its `layoutMargins`.
    ///
    /// - Note: The proxy provided by this property is based on the receiver's current `layoutMargins` and will not
    /// automatically update if the value of `layoutMargins` changes.
    public var layoutMarginsAlignmentProxy: Alignable {
        return InsetAlignmentProxy(proxiedView: self, insets: layoutMargins)
    }

}
