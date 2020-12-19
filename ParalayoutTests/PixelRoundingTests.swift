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

final class PixelRoundingTests: XCTestCase {

    // MARK: - Private Types

    private enum Samples {
        static let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        static let view = UIView()
    }

    // MARK: - XCTest

    override func setUp() {
        super.setUp()

        Samples.window.addSubview(Samples.view)
    }

    // MARK: - Tests - Pixel Rounding

    func testPixelRounding() {
        XCTAssert(CGFloat(1.75).floorToPixel(in: 0) == 1.75)
        XCTAssert(CGFloat(1.75).floorToPixel(in: TestScreen.at1x) == 1)
        XCTAssert(CGFloat(1.75).floorToPixel(in: TestScreen.at2x) == 1.5)
        XCTAssert(CGFloat(1.75).floorToPixel(in: TestScreen.at3x) == CGFloat(2) - 1 / 3)
        XCTAssert(CGFloat(-1.6).floorToPixel(in: TestScreen.at2x) == -2)

        XCTAssert(CGFloat(1.75).roundToPixel(in: 0) == 1.75)
        XCTAssert(CGFloat(1.75).roundToPixel(in: TestScreen.at1x) == 2)
        XCTAssert(CGFloat(1.75).roundToPixel(in: TestScreen.at2x) == 2)
        XCTAssert(CGFloat(1.75).roundToPixel(in: TestScreen.at3x) == CGFloat(2) - 1 / 3)
        XCTAssert(CGFloat(-1.6).roundToPixel(in: TestScreen.at3x) == CGFloat(-2) + 1 / 3)

        XCTAssert(CGFloat(1.25).ceilToPixel(in: 0) == 1.25)
        XCTAssert(CGFloat(1.25).ceilToPixel(in: TestScreen.at1x) == 2)
        XCTAssert(CGFloat(1.25).ceilToPixel(in: TestScreen.at2x) == 1.5)
        XCTAssert(CGFloat(1.25).ceilToPixel(in: TestScreen.at3x) == CGFloat(1) + 1 / 3)
        XCTAssert(CGFloat(-1.75).ceilToPixel(in: TestScreen.at2x) == -1.5)
    }

    func testViewPixelRounding() {
        // A view should inherit the scale factor of its parent screen.
        for screen in screensToTest() {
            Samples.window.screen = screen
            XCTAssertEqual(Samples.view.pixelsPerPoint, screen.pixelsPerPoint)
        }

        // With no superview, the main screen's scale should be used.
        Samples.view.removeFromSuperview()
        XCTAssert(Samples.view.pixelsPerPoint == UIScreen.main.pixelsPerPoint)
    }

    // MARK: - Private Methods

    private func screensToTest() -> [UIScreen] {
        if #available(iOS 13, *) {
            // In iOS 13 and later, there is a bug around setting `UIWindow.screen` that prevents us from testing
            // multiple screens (FB8674601).
            return [.main]

        } else {
            return TestScreen.all
        }
    }

}
