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


public extension UIView {
    
    /// Constraints on the result of a call to `sizeThatFits(:)` or `sizeToFit()`.
    /// - `default`: no adjustment.
    /// - `minWidth`: Use the supplied width or larger.
    /// - `maxWidth`: Use the supplied width or smaller.
    /// - `minHeight`: Use the supplied height or larger.
    /// - `maxHeight`: Use the supplied height or smaller.
    /// - `fixedWidth`: Use the supplied width regardless.
    /// - `fixedHeight`: Use the supplied height regardless.
    /// - `minSize`: Use the supplied size or larger.
    /// - `maxSize`: Use the supplied size or smaller.
    /// - `wrap`: Use the supplied width regardless, and the supplied height or smaller.
    struct SizingConstraints: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let minWidth = SizingConstraints(rawValue: 1 << 0)
        public static let maxWidth = SizingConstraints(rawValue: 1 << 1)
        public static let minHeight = SizingConstraints(rawValue: 1 << 2)
        public static let maxHeight = SizingConstraints(rawValue: 1 << 3)
        
        public static let none: SizingConstraints = []
        
        public static let fixedWidth: SizingConstraints = [ minWidth, maxWidth ]
        public static let fixedHeight: SizingConstraints = [ minHeight, maxHeight ]
        
        public static let minSize: SizingConstraints = [ minWidth, minHeight ]
        public static let maxSize: SizingConstraints = [ maxWidth, maxHeight ]
        public static let wrap: SizingConstraints = [ fixedWidth, maxHeight ]
        
        /// Apply the constraints to a given size.
        /// - parameter size: The size to constrain.
        /// - returns: A size with the receiver's constraints applied.
        public func apply(_ size: CGSize) -> CGSize {
            var constrainedSize = size
            
            if contains(.minWidth) {
                assert(size.width < CGFloat.greatestFiniteMagnitude, "Can't use CGFloat.max with minWidth!")
                constrainedSize.width = max(constrainedSize.width, size.width)
            }
            
            if contains(.maxWidth) {
                constrainedSize.width = min(constrainedSize.width, size.width)
            }
            
            if contains(.minHeight) {
                assert(size.height < CGFloat.greatestFiniteMagnitude, "Can't use CGFloat.max with minHeight!")
                constrainedSize.height = max(constrainedSize.height, size.height)
            }
            
            if contains(.maxHeight) {
                constrainedSize.height = min(constrainedSize.height, size.height)
            }
            
            return constrainedSize
        }
        
    }
    
    /// The frame size that "best" fits the supplied bounding size, with constraints applied.
    /// - parameter size: A bounding size within which the view should fit. Not a strict maximum.
    /// - parameter constraints: Limits on the returned size (optional, defaults to `.none`).
    /// - returns: A size for the receiver's `frame` that best fits its content.
    public func frameSize(thatFits size: CGSize, constraints: SizingConstraints = .none) -> CGSize {
        return constraints.apply(sizeThatFits(size))
    }
    
    /// The frame size that "best" fits the supplied bounding size, with constraints applied.
    /// - parameter width: A bounding width within which the view should fit (optional, defaults to `.greatestFiniteMagnitude`).
    /// - parameter height: A bounding height within which the view should fit (optional, defaults to `.greatestFiniteMagnitude`).
    /// - parameter constraints: Limits on the returned size (optional, defaults to `.none`).
    /// - returns: A size for the receiver's `frame` that best fits its content.
    public func frameSize(thatFitsWidth width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude, constraints: SizingConstraints = .none) -> CGSize {
        return frameSize(thatFits: CGSize(width: width, height: height), constraints: constraints)
    }
    
    /// Resize the view to fit a given size, with constraints applied.
    /// - parameter sizeToFit: The size to fit, typically the `superview.bounds` or smaller.
    /// - parameter constraints: Limits on the size to actually set (optional, defaults to `.none`).
    public func resize(toFit sizeToFit: CGSize, constraints: SizingConstraints = .none) {
        frame.size = frameSize(thatFits: sizeToFit, constraints: constraints)
    }
    
    /// Resize the view to fit a given width.
    /// - parameter width: the width to fit, passed through to `frameSize(thatFits:)`.
    /// - parameter height: the height to fit, passed through to `frameSize(thatFits:)` (optional, defaults to `greatestFiniteMagnitude`).
    /// - parameter constraints: Limits on the size to actually set (optional, defaults to `.none`).
    public func resize(toFitWidth width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, constraints: SizingConstraints = .none) {
        resize(toFit: CGSize(width: width, height: height), constraints: constraints)
    }
    
    /// Resize the view to fit a given size with insets.
    /// - parameter size: The size to fit, typically the `superview.bounds`.
    /// - parameter margins: An inset from the supplied size to use (optional, defaults to `0`).
    public func wrap(toFit size: CGSize, margins: CGFloat = 0) {
        resize(toFit: CGSize(width: max(0, size.width - 2 * margins), height: max(0, size.height - 2 * margins)), constraints: .wrap)
    }
    
    /// Resize the view to a set width, and unlimited height (e.g. when in a scroll view).
    /// - parameter width: the width to set.
    /// - parameter height: the height to fit (optional, defaults to `greatestFiniteMagnitude`).
    /// - parameter margins: An inset from the supplied width to use (optional, defaults to `0`).
    public func wrap(toFitWidth width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, margins: CGFloat = 0) {
        resize(toFit: CGSize(width: max(0, width - 2 * margins), height: max(0, height - 2 * margins)), constraints: .wrap)
    }
    
}
