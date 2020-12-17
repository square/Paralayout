//
//  Copyright © 2020 Square, Inc.
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

import CoreGraphics

public struct Angle: Comparable {

    // MARK: - Public Static Properties

    /// A zero angle.
    public static let zero = Angle(radians: 0)

    /// A right angle, representing 1/4 of a circle (90º, or π/2 radians).
    public static let right = Angle(radians: .pi / 2)

    /// A straight angle, representing 1/2 of a circle (180º, or π radians).
    public static let halfCircle = Angle(radians: .pi)

    /// An angle representing a full rotation around a circle (360º, or 2π radians).
    public static let fullCircle = Angle(radians: 2 * .pi)

    // MARK: - Life Cycle

    /// Create an angle in radians.
    public init(radians: CGFloat) {
        self.radians = radians
    }

    /// Create an angle in degrees.
    public init(degrees: CGFloat) {
        self.radians = Angle.radians(fromDegrees: degrees)
    }

    /// Create an angle, measured as the angle between two points, in the range `(-180°,180°]`.
    public init(from startPoint: CGPoint, to endPoint: CGPoint) {
        self.radians = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
    }

    // MARK: - Public Properties

    /// The "raw" value of the angle, expressed in radians (2π radians is 360°).
    public var radians: CGFloat

    /// The number of degress repesented by the angle (2π radians is 360°).
    public var degrees: CGFloat {
        get {
            return Angle.degrees(fromRadians: radians)
        }
        set {
            radians = Angle.radians(fromDegrees: newValue)
        }
    }

    /// Returns a new angle in the range `[0º,360°)`.
    public var normalizedPositive: Angle {
        return normalizing(around: .halfCircle)
    }

    /// Returns a new angle in the range `[-180°,180°)`.
    public var normalizedHalfCircle: Angle {
        return normalizing(around: .zero)
    }

    // MARK: - Public Methods

    public func point(atDistance distance: CGFloat, from origin: CGPoint) -> CGPoint {
        return CGPoint(
            x: origin.x + distance * cos(radians),
            y: origin.y + distance * sin(radians)
        )
    }

    // MARK: - Operators

    public static prefix func - (rhs: Angle) -> Angle {
        return Angle(radians: -rhs.radians)
    }

    public static func + (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians + rhs.radians)
    }

    public static func - (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians - rhs.radians)
    }

    public static func < (lhs: Angle, rhs: Angle) -> Bool {
        return (lhs.radians < rhs.radians)
    }

    public static func <= (lhs: Angle, rhs: Angle) -> Bool {
        return (lhs.radians <= rhs.radians)
    }

    public static func > (lhs: Angle, rhs: Angle) -> Bool {
        return (lhs.radians > rhs.radians)
    }

    public static func >= (lhs: Angle, rhs: Angle) -> Bool {
        return (lhs.radians >= rhs.radians)
    }

    // MARK: - Private Methods

    private func normalizing(around referenceAngle: Angle) -> Angle {
        var normalizedRadians = radians

        let fullCircleRadians = Angle.fullCircle.radians
        let minimumRadians = referenceAngle.radians - fullCircleRadians / 2
        let maximumRadians = minimumRadians + fullCircleRadians

        while normalizedRadians < minimumRadians {
            normalizedRadians += fullCircleRadians
        }

        while normalizedRadians >= maximumRadians {
            normalizedRadians -= fullCircleRadians
        }

        return Angle(radians: normalizedRadians)
    }

    // MARK: - Private Static Methods

    private static func radians(fromDegrees degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }

    private static func degrees(fromRadians radians: CGFloat) -> CGFloat {
        return radians * 180 / .pi
    }

}
