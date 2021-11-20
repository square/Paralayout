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
import XCTest

@testable import Paralayout

final class UIViewFrameTests: XCTestCase {

    // MARK: - Tests

    func testUntransformedFrameGetter_simpleFrames() {
        let view = UIView()

        view.frame = .zero
        assertUntransformedFrameIsAccurate(for: view)

        view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        assertUntransformedFrameIsAccurate(for: view)

        view.frame = CGRect(x: 10, y: 20, width: 30, height: 40)
        assertUntransformedFrameIsAccurate(for: view)
    }

    func testUntransformedFrameSetter_simpleFrames() {
        let view = UIView()

        let newValue = CGRect(x: 80, y: 70, width: 60, height: 50)
        view.untransformedFrame = newValue
        XCTAssertEqual(view.untransformedFrame, newValue)
    }

    func testUntransformedFrameGetter_nonIdentityTransform() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        view.transform = .init(scaleX: 2, y: 4)
        assertUntransformedFrameIsAccurate(for: view)

        view.transform = .init(rotationAngle: .pi / 5)
        assertUntransformedFrameIsAccurate(for: view)
    }

    func testUntransformedFrameSetter_nonIdentityTransform() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        let transform = CGAffineTransform(rotationAngle: .pi / 5)
        view.transform = transform

        let newValue = CGRect(x: 80, y: 70, width: 60, height: 50)
        view.untransformedFrame = newValue
        XCTAssertEqual(view.untransformedFrame, newValue)
        XCTAssertEqual(view.transform, transform)
    }

    func testUntransformedFrameGetter_nonCenterAnchorPoint() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        view.layer.anchorPoint = .init(x: 0, y: 0)
        assertUntransformedFrameIsAccurate(for: view)

        view.layer.anchorPoint = .init(x: 0.25, y: 0.75)
        assertUntransformedFrameIsAccurate(for: view)
    }

    func testUntransformedFrameSetter_nonCenterAnchorPoint() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        let anchorPoint = CGPoint(x: 0.25, y: 0.75)
        view.layer.anchorPoint = anchorPoint

        let newValue = CGRect(x: 80, y: 70, width: 60, height: 50)
        view.untransformedFrame = newValue
        XCTAssertEqual(view.untransformedFrame, newValue)
        XCTAssertEqual(view.layer.anchorPoint, anchorPoint)
    }

    func testUntransformedFrameGetter_nonZeroOriginBounds() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        view.bounds.origin = .init(x: 50, y: 60)
        assertUntransformedFrameIsAccurate(for: view)
    }

    func testUntransformedFrameSetter_nonZeroOriginBounds() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 30, height: 40))

        let boundsOrigin = CGPoint(x: 50, y: 60)
        view.bounds.origin = boundsOrigin

        let newValue = CGRect(x: 80, y: 70, width: 60, height: 50)
        view.untransformedFrame = newValue
        XCTAssertEqual(view.untransformedFrame, newValue)
        XCTAssertEqual(view.bounds.origin, boundsOrigin)
    }

    // MARK: - Private Helper Methods

    func assertUntransformedFrameIsAccurate(for view: UIView, file: StaticString = #file, line: UInt = #line) {
        let actualValue = view.untransformedFrame

        let originalTransform = view.layer.transform
        view.layer.transform = CATransform3DIdentity

        XCTAssertEqual(actualValue, view.frame, file: file, line: line)

        view.layer.transform = originalTransform
    }

}
