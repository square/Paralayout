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

/// A method for constraining a value.
public enum Clamp {

    /// No adjustment.
    case none

    /// Clamp values below the minimum.
    case minimum

    /// Clamp values above the maximum.
    case maximum

    /// Clamp values between minimum and maximum.
    case both

    // MARK: - Life Cycle
    
    /// Initialize a Clamp with optional min and max.
    public init(min: Bool, max: Bool) {
        if min {
            self = max ? .both : .minimum
        } else {
            self = max ? .maximum : .none
        }
    }

    // MARK: - Public Properties
    
    /// Whether or not the receiver clamps values above the minimum.
    public var clampsMinimum: Bool {
        switch  self {
        case .none, .maximum:
            return false
        case .minimum, .both:
            return true
        }
    }
    
    /// Whether or not the receiver clamps values below the maximum.
    public var clampsMaximum: Bool {
        switch  self {
        case .none, .minimum:
            return false
        case .maximum, .both:
            return true
        }
    }

    // MARK: - Public Methods
    
    /// Clamps the provided value between min/max.
    /// - parameter value: The value to clamp.
    /// - parameter minValue: The minimum value to return, if the receiver clamps to min.
    /// - parameter maxValue: The maximum value to return, if the receiver clamps to max.
    /// - returns: Either `value`, `minValue`, or `maxValue` as appropriate.
    public func apply<T>(_ value: T, min minValue: T, max maxValue: T) -> T where T: Comparable {
        switch self {
        case .none:
            return value
        case .minimum:
            return max(minValue, value)
        case .maximum:
            return min(maxValue, value)
        case .both:
            if maxValue < minValue {
                // Complain, but do the reasonable thing.
                assert(false, "Clamp given reversed min/max values!")
                return max(maxValue, min(minValue, value))
                
            } else {
                return max(minValue, min(maxValue, value))
            }
        }
    }
    
    /// Convenience method to clamp the provided value to [0...1].
    /// - parameter value: The value to clamp.
    /// - returns: Either `value`, `0.0`, or `1.0`.
    public func applyUnit(value: CGFloat) -> CGFloat {
        return apply(value, min: 0.0, max: 1.0)
    }
    
}

// MARK: -

public struct Interpolation: Comparable {

    // MARK: - Public Types
    
    public enum Curve {
        
        /// Interpolate linearly between start and end values.
        case linear
        
        /// Interpolate a parabolic ease-in.
        case easeIn
        
        /// Interpolate a parabolic ease-out.
        case easeOut
        
        /// Interpolate a sinusoidal ease-in-and-out.
        case easeInOut
        
        /// Interpolation based on a provided function operating on unit values `[0...1]`
        case custom(curveFunction: (CGFloat) -> CGFloat, approximateUIViewAnimationCurve: UIView.AnimationOptions)

        // MARK: - Life Cycle

        /// Initialize a Curve with optional ease in and out.
        public init(easeIn: Bool, easeOut: Bool) {
            if easeIn {
                self = easeOut ? .easeInOut : .easeIn
            } else {
                self = easeOut ? .easeOut : .linear
            }
        }

        // MARK: - Public Properties
        
        /// The equivalent UIViewAnimationOptions represented by the receiver.
        public var animationCurveOptions: UIView.AnimationOptions {
            switch self {
            case .linear:
                return .curveLinear
            case .easeIn:
                return .curveEaseIn
            case .easeOut:
                return .curveEaseOut
            case .easeInOut:
                return .curveEaseInOut
            case .custom(_, let approximateUIViewAnimationCurve):
                return approximateUIViewAnimationCurve
            }
        }

        // MARK: - Public Methods
        
        /// Re-normalize the provided progress based on the receiver's represented animation curve.
        /// - parameter progress: The progress to base the animation on.
        /// - returns: A new progress adjusted to represent the curve.
        public func reinterpolate(_ progress: Interpolation) -> Interpolation {
            let rawValue = progress.clamp().rawValue
            let curvedRawValue: CGFloat
            
            switch self {
            case .linear:
                curvedRawValue = rawValue
            case .easeIn:
                curvedRawValue = pow(rawValue, 2.0)
            case .easeOut:
                curvedRawValue = 1.0 - pow((rawValue - 1.0), 2.0)
            case .easeInOut:
                curvedRawValue = 0.5 - cos(rawValue * CGFloat.pi) * 0.5
            case .custom(let curveFunction, _):
                curvedRawValue = curveFunction(rawValue)
            }
            
            return Interpolation(rawValue: curvedRawValue)
        }
        
    }
    
    // MARK: - Public Static Properties
    
    /// A Interpolation value representing the start of a progression.
    public static let start = Interpolation(rawValue: startRawValue)
    
    /// A Interpolation value representing the midpoint of a progression.
    public static let middle = Interpolation(rawValue: (startRawValue + (endRawValue - startRawValue) / 2.0))
    
    /// A Interpolation value representing the end of a progression.
    public static let end = Interpolation(rawValue: endRawValue)
    
    // MARK: - Private Static Properties
    
    private static let startRawValue: CGFloat = 0.0
    private static let endRawValue: CGFloat = 1.0
    
    // MARK: - Public Properties

    /// The inverse progress, interpolated in [end...start].
    public var inverse: Interpolation {
        return Interpolation(rawValue: Interpolation.endRawValue - rawValue, clamp: .none)
    }

    // MARK: - Private Properties
    
    // This is private to ensure rigorous use of `interpolate()` to get values out, e.g.
    // `progress.interpolate(from: 0, to: 1)`
    private let rawValue: CGFloat
    
    // MARK: - Life Cycle
    
    // This is private since `rawValue` is private.
    private init(rawValue: CGFloat, clamp: Clamp = .both) {
        self.rawValue = clamp.apply(rawValue, min: Interpolation.startRawValue, max: Interpolation.endRawValue)
    }
    
    /// Initialize an Interpolation with a CGFloat.
    /// - parameter value: The value to normalize.
    /// - parameter min: The min value, corresponding to `.start`.
    /// - parameter max: The max value, corresponding to `.end`.
    /// - parameter clamp: The clamp to use for values outside `[min...max]` (optional, defaults to `.both`).
    public init(of value: CGFloat, from min: CGFloat, to max: CGFloat, clamp: Clamp = .both) {
        let rawValue = (max == min) ? Interpolation.endRawValue : ((value - min) / (max - min))
        self.init(rawValue: rawValue, clamp: clamp)
    }
    
    /// Initialize an Interpolation with a CGFloat.
    /// - parameter unitValue: The value to normalize in 0...1.
    /// - parameter clamp: The clamp options to use for values outside `[0...1]` (optional, defaults to `.both`).
    public init(ofUnit unitValue: CGFloat, clamp: Clamp = .both) {
        self.init(of: unitValue, from: 0.0, to: 1.0, clamp: clamp)
    }
    
    /// Initialize an Interpolation with an elapsed time.
    /// - parameter startDate: The start date from which to determine progress.
    /// - parameter duration: The duration of the progress.
    /// - parameter clamp: The clamp options to use for values outside `[startDate...startDate + duration]` (optional,
    /// defaults to `.both`).
    public init(since startDate: NSDate, duration: TimeInterval, clamp: Clamp = .both) {
        let rawValue = (duration == 0.0)
            ? Interpolation.endRawValue
            : CGFloat(startDate.timeIntervalSinceNow / -duration)
        self.init(rawValue: rawValue, clamp: clamp)
    }
    
    /// Initialize an Interpolation with another Interpolation.
    /// - parameter interpolation: The Interpolation to re-normalize.
    /// - parameter start: The alternate Interpolation corresponding to `.start`.
    /// - parameter end: The alternate Interpolation corresponding to `.end`.
    /// - parameter clamp: The clamp options to use for values outside `[start...end]` (optional, defaults to `.both`).
    public init(
        of interpolation: Interpolation,
        from start: Interpolation,
        to end: Interpolation,
        clamp: Clamp = .both
    ) {
        self = Interpolation(of: interpolation.rawValue, from: start.rawValue, to: end.rawValue, clamp: clamp)
    }
    
    // MARK: - Comparable
    
    public static func ==(lhs: Interpolation, rhs: Interpolation) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
    
    public static func <(lhs: Interpolation, rhs: Interpolation) -> Bool {
        return (lhs.rawValue < rhs.rawValue)
    }
    
    public static func <=(lhs: Interpolation, rhs: Interpolation) -> Bool {
        return (lhs.rawValue <= rhs.rawValue)
    }
    
    public static func >=(lhs: Interpolation, rhs: Interpolation) -> Bool {
        return (lhs.rawValue >= rhs.rawValue)
    }
    
    public static func >(lhs: Interpolation, rhs: Interpolation) -> Bool {
        return (lhs.rawValue > rhs.rawValue)
    }

    // MARK: - Public Methods
    
    /// Compute an interpolated value based on the Interpolation.
    /// - parameter min: The minimum value, corresponding to `.start`.
    /// - parameter max: The maximum value, corresponding to `.end`.
    /// - parameter curve: A curve to apply to the interpolation (optional, defaults to `.linear`).
    /// - returns: The interpolated value.
    public func interpolate(from min: CGFloat, to max: CGFloat, curve: Curve = .linear) -> CGFloat {
        return min + curve.reinterpolate(self).rawValue * (max - min)
    }
    
    /// Compute an interpolated value based on the Interpolation, with a midpoint value.
    /// - parameter min: The minimum value, corresponding to `.start`.
    /// - parameter startCurve: The curve to apply between `min` and `mid` (optional, defaults to `.linear`).
    /// - parameter mid: The midpoint value, corresponding to `midInterpolation`.
    /// - parameter midInterpolation: The midpoint Interpolation value (optional, defaults to `.middle`).
    /// - parameter endCurve: The curve to apply between `mid` and `max` (optional, defaults to `.linear`).
    /// - parameter to: The maximum value, corresponding to `.end`.
    /// - returns: The interpolated value.
    public func interpolate(
        from min: CGFloat,
        startCurve: Curve = .linear,
        through mid: CGFloat,
        at midInterpolation: Interpolation = .middle,
        endCurve: Curve = .linear,
        to max: CGFloat
    ) -> CGFloat {
        if self < midInterpolation {
            return renormalizing(from: .start, to: midInterpolation).interpolate(from: min, to: mid, curve: startCurve)
        } else {
            return renormalizing(from: midInterpolation, to: .end).interpolate(from: mid, to: max, curve: endCurve)
        }
    }
    
    /// Compute an interpolated coordinate based on the Interpolation.
    /// - parameter start: The initial coordinate, corresponding to `.start`.
    /// - parameter end: The final coordinate, corresponding to `.end`.
    /// - parameter curve: A curve to apply to the interpolation (optional, defaults to `.linear`).
    /// - returns: The interpolated coordinate.
    public func interpolate(from start: CGPoint, to end: CGPoint, curve: Curve = .linear) -> CGPoint {
        return CGPoint(
            x: interpolate(from: start.x, to: end.x, curve: curve),
            y: interpolate(from: start.y, to: end.y, curve: curve)
        )
    }
    
    /// Compute an interpolated size based on the Interpolation.
    /// - parameter start: The initial size, corresponding to `.start`.
    /// - parameter end: The final size, corresponding to `.end`.
    /// - parameter curve: A curve to apply to the interpolation (optional, defaults to `.linear`).
    /// - returns: The interpolated size.
    public func interpolate(from start: CGSize, to end: CGSize, curve: Curve = .linear) -> CGSize {
        return CGSize(
            width: interpolate(from: start.width, to: end.width, curve: curve),
            height: interpolate(from: start.height, to: end.height, curve: curve)
        )
    }

    /// Compute an interpolated rect based on the Interpolation.
    /// - parameter start: The initial rect, corresponding to `.start`.
    /// - parameter end: The final rect, corresponding to `.end`.
    /// - parameter curve: A curve to apply to the interpolation (optional, defaults to `.linear`).
    /// - returns: The interpolated rect.
    public func interpolate(from start: CGRect, to end: CGRect, curve: Curve = .linear) -> CGRect {
        return .init(
            origin: self.interpolate(from: start.origin, to: end.origin, curve: curve),
            size: self.interpolate(from: start.size, to: end.size, curve: curve)
        )
    }
    
    /// Clamps the receiver to `[start...end]`.
    /// - parameter clamp: The clamp options to use (optional, defaults to `.both`).
    /// - returns: The clamped Interpolation.
    public func clamp(_ clamp: Clamp = .both) -> Interpolation {
        return Interpolation(rawValue: rawValue, clamp: clamp)
    }
    
    /// Renormalize the receiver based on the provided boundary values.
    /// - parameter start: The value that should normalize to `.start`.
    /// - parameter end: The value that should normalize to `.end`.
    /// - parameter clamp: Options to clamp normalized values outside `[start...end]` (optional, defaults to `.both`).
    /// - returns: A Interpolation value.
    public func renormalizing(from start: Interpolation, to end: Interpolation, clamp: Clamp = .both) -> Interpolation {
        return Interpolation(of: self, from: start, to: end, clamp: clamp)
    }

}
