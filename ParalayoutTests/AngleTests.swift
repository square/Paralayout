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

import Paralayout
import XCTest

final class AngleTests: XCTestCase {

    func testConstants() {
        XCTAssertEqual(Angle.zero.radians, 0)
        XCTAssertEqual(Angle.right.degrees, 90, accuracy: 1e-4)
        XCTAssertEqual(Angle.halfCircle.degrees, 180, accuracy: 1e-4)
        XCTAssertEqual(Angle.fullCircle.degrees, 360, accuracy: 1e-4)
    }

    func testValueInitializers() {
        func assertRadianInitPreservesValue(_ radians: CGFloat) {
            XCTAssertEqual(Angle(radians: radians).radians, radians)
        }

        func assertDegreeInitPreservesValue(_ degrees: CGFloat) {
            XCTAssertEqual(Angle(degrees: degrees).degrees, degrees, accuracy: 1e-4)
        }

        let testValues: [CGFloat] = [ 0, 0.01, 1, .pi, 2 * .pi, 90, 180, 360, 400 ]
        for testValue in testValues {
            assertRadianInitPreservesValue(testValue)
            assertRadianInitPreservesValue(-testValue)
            assertDegreeInitPreservesValue(testValue)
            assertDegreeInitPreservesValue(-testValue)
        }
    }

    func testPointInitializer() {
        let rect = CGRect(x: -1, y: -1, width: 2, height: 2)
        let centerPoint = Position.center.point(in: rect, layoutDirection: .leftToRight)

        // Identical points should have a zero angle between them (and importantly not have a divide-by-zero result).
        XCTAssertEqual(Angle(from: centerPoint, to: centerPoint).degrees, 0, accuracy: 1e-20)

        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.rightCenter.point(in: rect, layoutDirection: .leftToRight)).degrees,
            0,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.bottomRight.point(in: rect, layoutDirection: .leftToRight)).degrees,
            45,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.bottomCenter.point(in: rect, layoutDirection: .leftToRight)).degrees,
            90,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.bottomLeft.point(in: rect, layoutDirection: .leftToRight)).degrees,
            135,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.leftCenter.point(in: rect, layoutDirection: .leftToRight)).degrees,
            180,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.topLeft.point(in: rect, layoutDirection: .leftToRight)).degrees,
            -135,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.topCenter.point(in: rect, layoutDirection: .leftToRight)).degrees,
            -90,
            accuracy: 1e-4
        )
        XCTAssertEqual(
            Angle(from: centerPoint, to: Position.topRight.point(in: rect, layoutDirection: .leftToRight)).degrees,
            -45,
            accuracy: 1e-4
        )
    }

    func testPointAtDistance() {
        let rect = CGRect(x: -1, y: -1, width: 2, height: 2)
        let diagonalUnit: CGFloat = sqrt(2)
        let centerPoint = Position.center.point(in: rect, layoutDirection: .leftToRight)

        func assertEqual(_ lhs: CGPoint, _ rhs: CGPoint, accuracy: CGFloat, file: StaticString, line: UInt) {
            XCTAssertEqual(lhs.x, rhs.x, accuracy: accuracy, file: file, line: line)
            XCTAssertEqual(lhs.y, rhs.y, accuracy: accuracy, file: file, line: line)
        }

        func assert(
            angleDegrees: CGFloat,
            atDistance distance: CGFloat,
            isAtPosition position: Position,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            // Test two equivalent values for the same angle.
            assertEqual(
                Angle(degrees: angleDegrees).point(atDistance: distance, from: centerPoint),
                position.point(in: rect, layoutDirection: .leftToRight),
                accuracy: 1e-4,
                file: file,
                line: line
            )
            assertEqual(
                Angle(degrees: angleDegrees - 360).point(atDistance: distance, from: centerPoint),
                position.point(in: rect, layoutDirection: .leftToRight),
                accuracy: 1e-4,
                file: file,
                line: line
            )
        }

        assert(angleDegrees: 0, atDistance: 1, isAtPosition: .rightCenter)
        assert(angleDegrees: 360, atDistance: 1, isAtPosition: .rightCenter)

        assert(angleDegrees: 45, atDistance: diagonalUnit, isAtPosition: .bottomRight)
        assert(angleDegrees: 90, atDistance: 1, isAtPosition: .bottomCenter)
        assert(angleDegrees: 135, atDistance: diagonalUnit, isAtPosition: .bottomLeft)

        assert(angleDegrees: 180, atDistance: 1, isAtPosition: .leftCenter)

        assert(angleDegrees: 225, atDistance: diagonalUnit, isAtPosition: .topLeft)
        assert(angleDegrees: 270, atDistance: 1, isAtPosition: .topCenter)
        assert(angleDegrees: 315, atDistance: diagonalUnit, isAtPosition: .topRight)

        assert(angleDegrees: 45, atDistance: -diagonalUnit, isAtPosition: .topLeft)
        assert(angleDegrees: 180, atDistance: -1, isAtPosition: .rightCenter)

        // A distance of zero should always result in the same point, regardless of the angle.
        let testDegrees: [CGFloat] = [ 0, 45, 90, 135, 180, 225, 270, 315, 360 ]
        for degrees in testDegrees {
            assert(angleDegrees: degrees, atDistance: 0, isAtPosition: .center)
        }
    }

    func testPositiveNormalization() {
        // In the range [0,2π), the angle should be unmutated.
        XCTAssertEqual(Angle.zero.normalizedPositive.radians, Angle.zero.radians)
        XCTAssertEqual(Angle.right.normalizedPositive.radians, Angle.right.radians)
        XCTAssertEqual(Angle.halfCircle.normalizedPositive.radians, Angle.halfCircle.radians)
        XCTAssertEqual(Angle(radians: 1.5 * .pi).normalizedPositive.radians, 1.5 * .pi)

        // A full rotation should come back as zero.
        XCTAssertEqual(Angle.fullCircle.normalizedPositive.radians, Angle.zero.radians, accuracy: 1e-4)

        // Anything over a full rotation should come back with the remainder.
        XCTAssertEqual(Angle(radians: 7.0).normalizedPositive.radians, 7.0 - 2.0 * .pi, accuracy: 1e-4)

        // Negative rotations should come back as the equivalent positive rotation.
        XCTAssertEqual(Angle(radians: -.pi / 2).normalizedPositive.radians, 1.5 * .pi, accuracy: 1e-4)
    }

    func testHalfCircleNormalization() {
        // In the range [-180º,180º), the angle should be unmutated.
        XCTAssertEqual(Angle.zero.normalizedHalfCircle.radians, Angle.zero.radians, accuracy: 1e-4)
        XCTAssertEqual(Angle.right.normalizedHalfCircle.radians, Angle.right.radians, accuracy: 1e-4)

        // A half circle rotation in either direction should prefer the negative value.
        XCTAssertEqual(Angle(degrees: -180).normalizedHalfCircle.degrees, -180, accuracy: 1e-4)
        XCTAssertEqual(Angle(degrees: 180).normalizedHalfCircle.degrees, -180, accuracy: 1e-4)

        // Angles outside of the range should be normalized.
        XCTAssertEqual(Angle(degrees: 270).normalizedHalfCircle.degrees, -90, accuracy: 1e-4)
        XCTAssertEqual(Angle(degrees: -270).normalizedHalfCircle.degrees, 90, accuracy: 1e-4)
    }

}
