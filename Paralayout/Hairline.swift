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


/// A view that provides sizing and positioning conveniences for 1-pixel hairlines.
public class Hairline: UIView {
    
    // MARK: - Class Methods
    
    /// Create an install a new Hairline instance into another view.
    /// - parameter superview: The view into which the new instance will be installed.
    /// - parameter edge: Where to position the instance (which also implies horizontal/vertical orientation).
    /// - parameter inset: A margin from the edges of `superview` to set the positioning and length of the instance (optional, defaults to `0`).
    /// - parameter autoresize: Whether or not to configure the appropriate `autoresizingMask` for the specified edge (optional, defaults to `false`).
    public class func new(in superview: UIView, at edge: CGRectEdge, inset: CGFloat = 0, autoresize: Bool = false) -> Hairline {
        let hairline = Hairline()
        
        superview.addSubview(hairline)
        hairline.spanSuperview(at: edge, inset: inset, updateAutoresizingMask: autoresize)
        
        return hairline
    }
    
    // MARK: - Properties
    
    /// Whether the hairline is horizontal or vertical.
    public var isHorizontal: Bool = true
    
    /// The hairline's length in the direction of its orientation, e.g. `frame.width` for a horizontal hairline.
    public var length: CGFloat {
        get {
            return isHorizontal ? frame.width : frame.height
        }
        
        set {
            if isHorizontal {
                frame.size.width = newValue
            } else {
                frame.size.height = newValue
            }
        }
    }
    
    // MARK: - UIView
    
    /// Return a size with the appropriate dimension set to the hairline width.
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if isHorizontal {
            return CGSize(width: size.width, height: hairlineWidth)
        } else {
            return CGSize(width: hairlineWidth, height: size.height)
        }
    }
    
    // MARK: - Public Methods
    
    /// Size and position the Hairline within its `superview`, along an edge. Hairlines not positioned at their superview's edge can be resized via `length` or `sizeToFit()`.
    /// - parameter edge: The edge at which to position the hairline (this can change `isHorizontal`).
    /// - parameter leadingInset: The inset from the superview at the left/top of the hairline (optional, defaults to `0`).
    /// - parameter trailingInset: The inset from the superview at the right/bottom of the hairline (optional, defaults to `0`).
    /// - parameter updateAutoresizingMask: Whether or not to update the `autoresizingMask` to match the specified `edge` (optional, defaults to `false`).
    public func spanSuperview(at edge: CGRectEdge, leadingInset: CGFloat = 0, trailingInset: CGFloat = 0, updateAutoresizingMask: Bool = false) {
        guard let superview = superview else {
            return
        }
        
        let superviewBounds = superview.bounds
        
        switch edge {
        case .minXEdge:
            isHorizontal = false
            
            frame = CGRect(x: superviewBounds.minX,
                           y: superviewBounds.minY + leadingInset,
                           width: hairlineWidth,
                           height: superviewBounds.height - (leadingInset + trailingInset))
            
            if updateAutoresizingMask {
                autoresizingMask = [ .flexibleHeight, .flexibleRightMargin ]
            }

        case .maxXEdge:
            isHorizontal = false
            
            frame = CGRect(x: superviewBounds.maxX - hairlineWidth,
                           y: superviewBounds.minY + leadingInset,
                           width: hairlineWidth,
                           height: superviewBounds.height - (leadingInset + trailingInset))
            
            if updateAutoresizingMask {
                autoresizingMask = [ .flexibleHeight, .flexibleLeftMargin ]
            }
            
        case .minYEdge:
            isHorizontal = true
            
            frame = CGRect(x: superviewBounds.minX + leadingInset,
                           y: superviewBounds.minY,
                           width: superviewBounds.width - (leadingInset + trailingInset),
                           height: hairlineWidth)
            
            if updateAutoresizingMask {
                autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
            }
            
        case .maxYEdge:
            isHorizontal = true
            
            frame = CGRect(x: superviewBounds.minX + leadingInset,
                           y: superviewBounds.maxY - hairlineWidth,
                           width: superviewBounds.width - (leadingInset + trailingInset),
                           height: hairlineWidth)
            
            if updateAutoresizingMask {
                autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]
            }
        }
    }
    
    /// Size and position the Hairline within its `superview`, along an edge. Hairlines not positioned at their superview's edge can be resized via `length` or `sizeToFit()`.
    /// - parameter edge: The edge at which to position the hairline (this can change `isHorizontal`).
    /// - parameter inset: The inset from the superview at the start and end of the hairline.
    /// - parameter updateAutoresizingMask: Whether or not to update the `autoresizingMask` to match the specified `edge` (optional, defaults to `false`).
    public func spanSuperview(at edge: CGRectEdge, inset: CGFloat, updateAutoresizingMask: Bool = false) {
        spanSuperview(at: edge, leadingInset: inset, trailingInset: inset, updateAutoresizingMask: updateAutoresizingMask)
    }
    
}


// MARK: - Extensions


public extension UIScreen {
    
    /// Returns the width of a hairline (in points) for a given scale factor.
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` for the theoretical "real" size).
    /// - returns: The width, in points, of a hairline.
    public static func hairlineWidth(for scaleFactor: ScaleFactorProviding) -> CGFloat {
        // A hairline is 1/2 pt thick, rounded down to the nearest whole (non-zero) pixel.
        let hairline = CGFloat(0.5).floorToPixel(in: scaleFactor)
        return (hairline > 0.0) ? hairline : CGFloat(0.5).ceilToPixel(in: scaleFactor)
    }
    
    /// The width of a hairline (in points) for the receiver's scale factor.
    public var hairlineWidth: CGFloat {
        return UIScreen.hairlineWidth(for: self)
    }
    
}

public extension UIView {
    
    private static let defaultHairlineWidth = UIScreen.main.hairlineWidth
    
    /// The width of a hairline (in points) for the receiver's screen's scale factor (or `UIScreen.main` if not onscreen).
    public var hairlineWidth: CGFloat {
        if let selfAsWindow = self as? UIWindow {
            // A window's `window` is nil.
            return selfAsWindow.screen.hairlineWidth
            
        } else {
            return window?.screen.hairlineWidth ?? UIView.defaultHairlineWidth
        }
    }
    
}
