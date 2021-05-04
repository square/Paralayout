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

import Paralayout
import UIKit
import XCTest

final class InterpolationTests: XCTestCase {

    // MARK: - CGRect

    func testCGRectInterpolation() {
        let startRect = CGRect(x: 1, y: 2, width: 5, height: 6)
        let endRect = CGRect(x: 3, y: 4, width: 7, height: 8)
        let actualRect = Interpolation.middle.interpolate(from: startRect, to: endRect)
        let expectedRect = CGRect(origin: CGPoint(x: 2, y: 3), size: CGSize(width: 6, height: 7))

        XCTAssertEqual(actualRect, expectedRect)
    }

    // MARK: - Float

    func testLinearFloatInterpolation_fromMinToMax() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max)

        XCTAssertEqual(interpolation, 3)
    }

    func testEaseInFloatInterpolation_fromMinToMax() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeIn)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseOutFloatInterpolation_fromMinToMax() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeOut)

        XCTAssertEqual(interpolation, 4)
    }

    func testEaseInOutFloatInterpolation_fromMinToMax() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeInOut)

        XCTAssertEqual(interpolation, 3)
    }

    func testLinearFloatInterpolation_ofUnit() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseInFloatInterpolation_ofUnit() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeIn)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseOutFloatInterpolation_ofUnit() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeOut)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseInOutFloatInterpolation_ofUnit() {
        let value: Float = 3.0
        let min: Float = 1.0
        let max: Float = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeInOut)

        XCTAssertEqual(interpolation, 5)
    }

    func testLinearFloatInterpolation_fromMinToMax_withMidpoint() {
        let value: Float = 3.0
        let min: Float = 1.0
        let mid: Float = 2.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, through: mid, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseInFloatInterpolation_fromMinToMax_withMidpoint() {
        let value: Float = 3.0
        let min: Float = 1.0
        let mid: Float = 2.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeIn, through: mid, endCurve: .easeIn, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseOutFloatInterpolation_fromMinToMax_withMidpoint() {
        let value: Float = 3.0
        let min: Float = 1.0
        let mid: Float = 2.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeOut, through: mid, endCurve: .easeOut, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseInOutFloatInterpolation_fromMinToMax_withMidpoint() {
        let value: Float = 3.0
        let min: Float = 1.0
        let mid: Float = 2.0
        let max: Float = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeInOut, through: mid, endCurve: .easeInOut, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    // MARK: - Double

    func testLinearDoubleInterpolation_fromMinToMax() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max)

        XCTAssertEqual(interpolation, 3)
    }

    func testEaseInDoubleInterpolation_fromMinToMax() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeIn)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseOutDoubleInterpolation_fromMinToMax() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeOut)

        XCTAssertEqual(interpolation, 4)
    }

    func testEaseInOutDoubleInterpolation_fromMinToMax() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, to: max, curve: .easeInOut)

        XCTAssertEqual(interpolation, 3)
    }

    func testLinearDoubleInterpolation_ofUnit() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseInDoubleInterpolation_ofUnit() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeIn)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseOutDoubleInterpolation_ofUnit() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeOut)

        XCTAssertEqual(interpolation, 5)
    }

    func testEaseInOutDoubleInterpolation_ofUnit() {
        let value: Double = 3.0
        let min: Double = 1.0
        let max: Double = 5.0
        let interpolation = Interpolation(ofUnit: value).interpolate(from: min, to: max, curve: .easeInOut)

        XCTAssertEqual(interpolation, 5)
    }

    func testLinearDoubleInterpolation_fromMinToMax_withMidpoint() {
        let value: Double = 3.0
        let min: Double = 1.0
        let mid: Double = 2.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, through: mid, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseInDoubleInterpolation_fromMinToMax_withMidpoint() {
        let value: Double = 3.0
        let min: Double = 1.0
        let mid: Double = 2.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeIn, through: mid, endCurve: .easeIn, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseOutDoubleInterpolation_fromMinToMax_withMidpoint() {
        let value: Double = 3.0
        let min: Double = 1.0
        let mid: Double = 2.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeOut, through: mid, endCurve: .easeOut, to: max)

        XCTAssertEqual(interpolation, 2)
    }

    func testEaseInOutDoubleInterpolation_fromMinToMax_withMidpoint() {
        let value: Double = 3.0
        let min: Double = 1.0
        let mid: Double = 2.0
        let max: Double = 5.0
        let interpolation = Interpolation(of: value, from: min, to: max)
            .interpolate(from: min, startCurve: .easeInOut, through: mid, endCurve: .easeInOut, to: max)

        XCTAssertEqual(interpolation, 2)
    }

}
