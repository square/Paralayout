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
import UIKit
import XCTest

final class PixelRoundingTests: XCTestCase {

    // MARK: - Tests - Pixel Rounding

    @MainActor
    func testFloatPixelRounding() {
        XCTAssertEqual(CGFloat(1.75).flooredToPixel(in: 0), 1.75)
        XCTAssertEqual(CGFloat(1.75).flooredToPixel(in: TestScreen.at1x), 1)
        XCTAssertEqual(CGFloat(1.75).flooredToPixel(in: TestScreen.at2x), 1.5)
        XCTAssertEqual(CGFloat(1.75).flooredToPixel(in: TestScreen.at3x), CGFloat(2) - 1 / 3)
        XCTAssertEqual(CGFloat(-1.6).flooredToPixel(in: TestScreen.at2x), -2)

        XCTAssertEqual(CGFloat(1.75).roundedToPixel(in: 0), 1.75)
        XCTAssertEqual(CGFloat(1.75).roundedToPixel(in: TestScreen.at1x), 2)
        XCTAssertEqual(CGFloat(1.75).roundedToPixel(in: TestScreen.at2x), 2)
        XCTAssertEqual(CGFloat(1.75).roundedToPixel(in: TestScreen.at3x), CGFloat(2) - 1 / 3)
        XCTAssertEqual(CGFloat(-1.6).roundedToPixel(in: TestScreen.at3x), CGFloat(-2) + 1 / 3)

        XCTAssertEqual(CGFloat(1.25).ceiledToPixel(in: 0), 1.25)
        XCTAssertEqual(CGFloat(1.25).ceiledToPixel(in: TestScreen.at1x), 2)
        XCTAssertEqual(CGFloat(1.25).ceiledToPixel(in: TestScreen.at2x), 1.5)
        XCTAssertEqual(CGFloat(1.25).ceiledToPixel(in: TestScreen.at3x), CGFloat(1) + 1 / 3)
        XCTAssertEqual(CGFloat(-1.75).ceiledToPixel(in: TestScreen.at2x), -1.5)
    }

    @MainActor
    func testPointPixelRounding() {
        XCTAssertEqual(CGPoint(x: 0.9, y: -1.1).flooredToPixel(in: 0), CGPoint(x: 0.9, y: -1.1))
        XCTAssertEqual(CGPoint(x: 0.9, y: -1.1).flooredToPixel(in: 1), CGPoint(x: 0, y: -2))
        XCTAssertEqual(CGPoint(x: 0.9, y: -1.1).flooredToPixel(in: 2), CGPoint(x: 0.5, y: -1.5))

        XCTAssertEqual(CGPoint(x: 0.1, y: -1.9).ceiledToPixel(in: 0), CGPoint(x: 0.1, y: -1.9))
        XCTAssertEqual(CGPoint(x: 0.1, y: -1.9).ceiledToPixel(in: 1), CGPoint(x: 1, y: -1))
        XCTAssertEqual(CGPoint(x: 0.1, y: -1.9).ceiledToPixel(in: 2), CGPoint(x: 0.5, y: -1.5))

        XCTAssertEqual(CGPoint(x: 0.4, y: -1.4).roundedToPixel(in: 0), CGPoint(x: 0.4, y: -1.4))
        XCTAssertEqual(CGPoint(x: 0.4, y: -1.4).roundedToPixel(in: 1), CGPoint(x: 0, y: -1))
        XCTAssertEqual(CGPoint(x: 0.4, y: -1.4).roundedToPixel(in: 2), CGPoint(x: 0.5, y: -1.5))
    }

    @MainActor
    func testSizePixelRounding() {
        XCTAssertEqual(CGSize(width: 0.9, height: -1.1).flooredToPixel(in: 0), CGSize(width: 0.9, height: -1.1))
        XCTAssertEqual(CGSize(width: 0.9, height: -1.1).flooredToPixel(in: 1), CGSize(width: 0, height: -2))
        XCTAssertEqual(CGSize(width: 0.9, height: -1.1).flooredToPixel(in: 2), CGSize(width: 0.5, height: -1.5))

        XCTAssertEqual(CGSize(width: 0.1, height: -1.9).ceiledToPixel(in: 0), CGSize(width: 0.1, height: -1.9))
        XCTAssertEqual(CGSize(width: 0.1, height: -1.9).ceiledToPixel(in: 1), CGSize(width: 1, height: -1))
        XCTAssertEqual(CGSize(width: 0.1, height: -1.9).ceiledToPixel(in: 2), CGSize(width: 0.5, height: -1.5))

        XCTAssertEqual(CGSize(width: 0.4, height: -1.4).roundedToPixel(in: 0), CGSize(width: 0.4, height: -1.4))
        XCTAssertEqual(CGSize(width: 0.4, height: -1.4).roundedToPixel(in: 1), CGSize(width: 0, height: -1))
        XCTAssertEqual(CGSize(width: 0.4, height: -1.4).roundedToPixel(in: 2), CGSize(width: 0.5, height: -1.5))
    }

    @MainActor
    func testRectPixelRounding() {
        XCTAssertEqual(
            CGRect(left: 10.6, top: 10.4, right: 50.6, bottom: 50.6).expandedToPixel(in: TestScreen.at2x),
            CGRect(left: 10.5, top: 10.0, right: 51, bottom: 51)
        )
        XCTAssertEqual(
            CGRect(left: 10.7, top: 10.4, right: 50.5, bottom: 50.7).expandedToPixel(in: TestScreen.at3x),
            CGRect(left: CGFloat(10) + 2 / 3, top: CGFloat(10) + 1 / 3, right: CGFloat(50) + 2 / 3, bottom: 51)
        )

        XCTAssertEqual(
            CGRect(left: 10.6, top: 10.4, right: 50.6, bottom: 50.6).contractedToPixel(in: TestScreen.at2x),
            CGRect(left: 11, top: 10.5, right: 50.5, bottom: 50.5)
        )
        XCTAssertEqual(
            CGRect(left: 10.7, top: 10.4, right: 50.5, bottom: 50.7).contractedToPixel(in: TestScreen.at3x),
            CGRect(left: 11, top: CGFloat(10) + 2 / 3, right: CGFloat(50) + 1 / 3, bottom: CGFloat(50) + 2 / 3)
        )
    }

}
