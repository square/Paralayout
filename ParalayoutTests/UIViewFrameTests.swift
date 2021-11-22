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

    func testUntransformedConvert_siblingViews() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let view1 = UIView(frame: CGRect(x: 20, y: 30, width: 40, height: 50))
        window.addSubview(view1)

        let view2 = UIView(frame: CGRect(x: 90, y: 80, width: 70, height: 60))
        window.addSubview(view2)

        try assertUntransformedConvertIsAccurate(for: .zero, in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: .zero, in: view2, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view2, convertedTo: view1)

        let containerView = UIView(frame: CGRect(x: 4, y: 5, width: 100, height: 100))
        containerView.addSubview(view1)
        containerView.addSubview(view2)
        window.addSubview(containerView)

        try assertUntransformedConvertIsAccurate(for: .zero, in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: .zero, in: view2, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view2, convertedTo: view1)

        window.frame.origin = .init(x: -7, y: 8)

        try assertUntransformedConvertIsAccurate(for: .zero, in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: .zero, in: view2, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 2, y: 3), in: view2, convertedTo: view1)
    }

    func testUntransformedConvert_verticalHierarchy() throws {
        let view1 = UIView(frame: CGRect(x: 1, y: 2, width: 10, height: 10))

        let view2 = UIView(frame: CGRect(x: 3, y: 4, width: 10, height: 10))
        view2.addSubview(view1)

        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 5, y: -6), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 5, y: -6), in: view2, convertedTo: view1)

        let view3 = UIView(frame: CGRect(x: 5, y: 6, width: 10, height: 10))
        view2.addSubview(view3)

        try assertUntransformedConvertIsAccurate(for: CGPoint(x: -7, y: 8), in: view1, convertedTo: view3)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: -7, y: 8), in: view3, convertedTo: view1)
    }

    func testUntransformedConvert_nonZeroBounds() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let view1 = UIView(frame: CGRect(x: 20, y: 30, width: 40, height: 50))
        window.addSubview(view1)

        let containerView = UIView(frame: CGRect(x: 40, y: 50, width: 60, height: 70))
        containerView.bounds.origin = CGPoint(x: 3, y: 4)
        window.addSubview(containerView)

        let view2 = UIView(frame: CGRect(x: 90, y: 80, width: 70, height: 60))
        containerView.addSubview(view2)

        let view3 = UIView(frame: CGRect(x: 110, y: 120, width: 20, height: 30))
        containerView.addSubview(view3)

        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 1, y: 2), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 1, y: 2), in: view2, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 1, y: 2), in: view2, convertedTo: view3)
    }

    func testUntransformedConvert_nonIdentityTransforms() throws {
        let view1 = UIView(frame: CGRect(x: 1, y: 2, width: 10, height: 10))
        view1.transform = .init(rotationAngle: 0.1)

        let view2 = UIView(frame: CGRect(x: 3, y: 4, width: 10, height: 10))
        view2.transform = .init(rotationAngle: 0.2)
        view2.addSubview(view1)

        let view3 = UIView(frame: CGRect(x: 5, y: 6, width: 10, height: 10))
        view3.transform = .init(rotationAngle: 0.3)

        let containerView = UIView(frame: CGRect(x: 7, y: 8, width: 100, height: 100))
        containerView.transform = .init(translationX: 50, y: 60)
        containerView.addSubview(view2)
        containerView.addSubview(view3)

        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view1, convertedTo: view2)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view1, convertedTo: view3)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view2, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view2, convertedTo: view3)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view3, convertedTo: view1)
        try assertUntransformedConvertIsAccurate(for: CGPoint(x: 8, y: -9), in: view3, convertedTo: view2)
    }

    // MARK: - Private Helper Methods

    func assertUntransformedFrameIsAccurate(for view: UIView, file: StaticString = #file, line: UInt = #line) {
        let actualValue = view.untransformedFrame

        let originalTransform = view.layer.transform
        view.layer.transform = CATransform3DIdentity

        XCTAssertEqual(actualValue, view.frame, file: file, line: line)

        view.layer.transform = originalTransform
    }

    func assertUntransformedConvertIsAccurate(
        for point: CGPoint,
        in sourceView: UIView,
        convertedTo targetView: UIView,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let actualValue = try targetView.untransformedConvert(point, from: sourceView)

        let viewsInHierarchyWithOriginalTransforms = Set(sequence(first: sourceView, next: { $0.superview }))
            .union(sequence(first: targetView, next: { $0.superview }))
            .map { ($0, $0.transform) }

        viewsInHierarchyWithOriginalTransforms.forEach { view, _ in
            view.transform = .identity
        }

        let expectedValue = targetView.convert(point, from: sourceView)
        XCTAssertEqual(actualValue, expectedValue, file: file, line: line)

        viewsInHierarchyWithOriginalTransforms.forEach { view, originalTransform in
            view.transform = originalTransform
        }
    }

}
