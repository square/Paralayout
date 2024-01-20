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
import SnapshotTesting

final class ViewAlignmentSnapshotTests: SnapshotTestCase {

    func testSiblingAlignment() {
        let containerView = UIView(frame: .init(x: 0, y: 0, width: 200, height: 200))
        containerView.backgroundColor = .white

        let firstSubview = UIView(frame: .init(x: 60, y: 80, width: 50, height: 70))
        firstSubview.backgroundColor = .green
        containerView.addSubview(firstSubview)

        let secondSubview = UIView(frame: .init(x: -10, y: -40, width: 30, height: 40))
        secondSubview.backgroundColor = .red
        containerView.addSubview(secondSubview)

        func verifySnapshot(
            receiverPosition: Position,
            targetPosition: Position,
            horizontalOffset: CGFloat = 0,
            verticalOffset: CGFloat = 0,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            // Force everything to LTR for now to simplify the test.
            containerView.semanticContentAttribute = .forceLeftToRight
            firstSubview.semanticContentAttribute = .forceLeftToRight
            secondSubview.semanticContentAttribute = .forceLeftToRight

            secondSubview.align(
                receiverPosition,
                with: firstSubview,
                targetPosition,
                horizontalOffset: horizontalOffset,
                verticalOffset: verticalOffset
            )

            assertSnapshot(
                matching: containerView,
                as: .image,
                named: nameForSnapshot(
                    with: [
                        "aligning" + receiverPosition.testDescription + "To" + targetPosition.testDescription,
                        (horizontalOffset < 0 ? "negativeHorizontalOffset" : nil),
                        (horizontalOffset > 0 ? "positiveHorizontalOffset" : nil),
                        (verticalOffset < 0 ? "negativeVerticalOffset" : nil),
                        (verticalOffset > 0 ? "positiveVerticalOffset" : nil),
                    ]
                ),
                file: file,
                testName: testName,
                line: line
            )
        }

        verifySnapshot(receiverPosition: .center, targetPosition: .topRight)

        // Test horizontal and vertical offsets.
        verifySnapshot(receiverPosition: .center, targetPosition: .topRight, horizontalOffset: 0)
        verifySnapshot(receiverPosition: .center, targetPosition: .topRight, horizontalOffset: -20)
        verifySnapshot(receiverPosition: .center, targetPosition: .topRight, verticalOffset: 15)
        verifySnapshot(receiverPosition: .center, targetPosition: .topRight, verticalOffset: -15)
    }

    func testLayoutDirection() {
        let containerView = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        containerView.backgroundColor = .white

        let targetView = UIView(frame: .init(x: 25, y: 25, width: 50, height: 50))
        targetView.backgroundColor = .lightGray
        containerView.addSubview(targetView)

        func addAlignedSubview(
            receiverPosition: Position,
            receiverLayoutDirection: UIUserInterfaceLayoutDirection,
            targetPosition: Position,
            targetLayoutDirection: UIUserInterfaceLayoutDirection,
            color: UIColor
        ) {
            let subview = UIView(frame: .init(x: 0, y: 0, width: 20, height: 20))
            subview.backgroundColor = color
            containerView.addSubview(subview)

            subview.semanticContentAttribute = .attributeToForce(receiverLayoutDirection)
            targetView.semanticContentAttribute = .attributeToForce(targetLayoutDirection)

            subview.align(receiverPosition, with: targetView, targetPosition)
        }

        addAlignedSubview(
            receiverPosition: .topLeading,
            receiverLayoutDirection: .leftToRight,
            targetPosition: .topTrailing,
            targetLayoutDirection: .leftToRight,
            color: .red
        )

        addAlignedSubview(
            receiverPosition: .topTrailing,
            receiverLayoutDirection: .leftToRight,
            targetPosition: .topTrailing,
            targetLayoutDirection: .rightToLeft,
            color: .green
        )

        addAlignedSubview(
            receiverPosition: .bottomTrailing,
            receiverLayoutDirection: .rightToLeft,
            targetPosition: .bottomTrailing,
            targetLayoutDirection: .leftToRight,
            color: .blue
        )

        addAlignedSubview(
            receiverPosition: .bottomLeading,
            receiverLayoutDirection: .rightToLeft,
            targetPosition: .bottomTrailing,
            targetLayoutDirection: .rightToLeft,
            color: .orange
        )

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testTransformHasNoEffect() {
        let containerView = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        containerView.backgroundColor = .white

        let firstSubview = UIView(frame: .init(x: 30, y: 30, width: 40, height: 40))
        firstSubview.backgroundColor = .green
        containerView.addSubview(firstSubview)

        let secondSubview = UIView(frame: .init(x: 0, y: 0, width: 25, height: 25))
        secondSubview.backgroundColor = .red
        containerView.addSubview(secondSubview)

        func verifySnapshot(
            receiverTransform: CGAffineTransform,
            targetTransform: CGAffineTransform,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            secondSubview.transform = receiverTransform
            firstSubview.transform = targetTransform

            secondSubview.align(.center, with: firstSubview, .topRight)

            secondSubview.transform = .identity
            firstSubview.transform = .identity

            // Note that all of the configurations use the same snapshot name, so there will only be one snapshot. This
            // is intentional, since the goal of this test is to verify that the different transform values have no
            // effect on the layout.
            assertSnapshot(
                matching: containerView,
                as: .image,
                named: nameForSnapshot(with: []),
                file: file,
                testName: testName,
                line: line
            )
        }

        verifySnapshot(receiverTransform: .identity, targetTransform: .identity)
        verifySnapshot(receiverTransform: .init(rotationAngle: 0.5), targetTransform: .identity)
        verifySnapshot(receiverTransform: .identity, targetTransform: .init(scaleX: 2, y: 3))
    }

    func testNonZeroBoundsOrigin() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        containerView.backgroundColor = .white

        let scrollView = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        scrollView.bounds.origin = CGPoint(x: 25, y: 25)
        scrollView.backgroundColor = .lightGray
        containerView.addSubview(scrollView)

        for position in [Position.topLeft, .topRight, .bottomLeft, .bottomRight] {
            let cornerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            cornerView.backgroundColor = .red
            containerView.addSubview(cornerView)

            cornerView.align(position, with: scrollView, position)
        }

        for position in [Position.topLeft, .topRight, .bottomLeft, .bottomRight] {
            let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            contentView.backgroundColor = .blue
            scrollView.addSubview(contentView)

            contentView.align(position, with: scrollView, position)
        }

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testAlignmentWithLayoutMargins() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        containerView.backgroundColor = .white

        let targetView = LayoutMarginsView(frame: CGRect(x: 25, y: 25, width: 150, height: 150))
        targetView.layoutMargins = .init(uniform: 20)
        targetView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        targetView.insetView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        containerView.addSubview(targetView)

        let receiverView = LayoutMarginsView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        receiverView.layoutMargins = .init(uniform: 10)
        receiverView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        receiverView.insetView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        containerView.addSubview(receiverView)

        receiverView.align(.bottomRight, with: targetView, .bottomRight)
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["noLayoutMargins"]))

        receiverView.align(.bottomRight, with: targetView.layoutMarginsAlignmentProxy, .bottomRight)
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["targetLayoutMargins"]))

        receiverView.layoutMarginsAlignmentProxy.align(.bottomRight, with: targetView, .bottomRight)
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["receiverLayoutMargins"]))

        receiverView.layoutMarginsAlignmentProxy.align(
            .bottomRight,
            with: targetView.layoutMarginsAlignmentProxy,
            .bottomRight
        )
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["bothLayoutMargins"]))
    }

    func testAlignmentUsingCapInsets() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        containerView.backgroundColor = .white

        let targetView = UIView(frame: containerView.bounds.insetAllSides(by: 20))
        targetView.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        containerView.addSubview(targetView)

        for position in [Position.topLeft, .topRight, .bottomRight, .bottomLeft] {
            let label = UILabel()
            label.text = "HÉLLÖ Worldy"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .black
            label.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            label.sizeToFit()
            containerView.addSubview(label)

            label.capInsetsAlignmentProxy.align(position, with: targetView, position)
        }

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testAlignmentUsingFirstLine() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        containerView.backgroundColor = .white

        let targetView = UIView(frame: CGRect(x: 20, y: 20, width: 8, height: 8))
        targetView.layer.cornerRadius = 4
        targetView.backgroundColor = .blue
        containerView.addSubview(targetView)

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.text = "Some text that needs to wrap to multiple lines"
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.sizeToFit(width: 160, constraints: .maxWidth)
        containerView.addSubview(label)

        label.firstLineAlignmentProxy.align(.leftCenter, with: targetView, .leftCenter, horizontalOffset: 16)

        for position in [Position.topLeft, .topRight, .bottomRight, .bottomLeft] {
            let cornerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            cornerView.backgroundColor = .red
            containerView.addSubview(cornerView)
            cornerView.align(position, with: label.firstLineAlignmentProxy, position)
        }

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testAlignmentUsingFirstLineCapInsets() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        containerView.backgroundColor = .white

        let targetView = UIView(frame: CGRect(x: 20, y: 20, width: 8, height: 8))
        targetView.layer.cornerRadius = 4
        targetView.backgroundColor = .blue
        containerView.addSubview(targetView)

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.text = "Some text that needs to wrap to multiple lines"
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.sizeToFit(width: 160, constraints: .maxWidth)
        containerView.addSubview(label)

        label.firstLineCapInsetsAlignmentProxy.align(.leftCenter, with: targetView, .leftCenter, horizontalOffset: 16)

        for position in [Position.topLeft, .topRight, .bottomRight, .bottomLeft] {
            let cornerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            cornerView.backgroundColor = .red
            containerView.addSubview(cornerView)
            cornerView.align(position, with: label.firstLineCapInsetsAlignmentProxy, position)
        }

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testAlignmentWithRect() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        containerView.backgroundColor = .white

        let alignmentProxy = RectAlignmentProxy(
            proxiedView: containerView,
            rect: CGRect(x: 40, y: 30, width: 150, height: 120)
        )

        let topLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        topLeftView.backgroundColor = UIColor.red
        containerView.addSubview(topLeftView)
        topLeftView.align(.topLeft, with: alignmentProxy, .topLeft)

        let topRightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        topRightView.backgroundColor = UIColor.green
        containerView.addSubview(topRightView)
        topRightView.align(.topRight, with: alignmentProxy, .topRight)

        let bottomLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        bottomLeftView.backgroundColor = UIColor.blue
        containerView.addSubview(bottomLeftView)
        bottomLeftView.align(.bottomLeft, with: alignmentProxy, .bottomLeft)

        let bottomRightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        bottomRightView.backgroundColor = UIColor.yellow
        containerView.addSubview(bottomRightView)
        bottomRightView.align(.bottomRight, with: alignmentProxy, .bottomRight)

        let overlayView = UIView(frame: CGRect(x: 40, y: 30, width: 150, height: 120))
        overlayView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        containerView.addSubview(overlayView)

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
    }

    func testAlignmentWithFrame() {
        let targetTransform = CGAffineTransform(translationX: -20, y: 10)
        let receiverTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        containerView.backgroundColor = .white

        let targetFrameView = UIView()
        targetFrameView.backgroundColor = UIColor.red.withAlphaComponent(0.15)
        containerView.addSubview(targetFrameView)

        let receiverFrameView = UIView()
        receiverFrameView.backgroundColor = UIColor.green.withAlphaComponent(0.15)
        containerView.addSubview(receiverFrameView)

        let targetView = UIView(frame: CGRect(x: 30, y: 30, width: 140, height: 140))
        targetView.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        targetView.transform = targetTransform
        containerView.addSubview(targetView)

        let receiverView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        receiverView.backgroundColor = UIColor.green.withAlphaComponent(0.4)
        receiverView.transform = receiverTransform
        containerView.addSubview(receiverView)

        func updateMirrorViews() {
            targetView.transform = .identity
            targetFrameView.frame = targetView.frame.applying(targetView.transform.inverted())
            targetView.transform = targetTransform

            receiverView.transform = .identity
            receiverFrameView.frame = receiverView.frame.applying(receiverView.transform.inverted())
            receiverView.transform = receiverTransform
        }

        receiverView.align(.bottomRight, with: targetView, .bottomRight)
        updateMirrorViews()
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["noProxies"]))

        receiverView.align(.bottomRight, with: targetView.frameAlignmentProxy, .bottomRight)
        updateMirrorViews()
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["targetProxy"]))

        receiverView.frameAlignmentProxy.align(.bottomRight, with: targetView, .bottomRight)
        updateMirrorViews()
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["receiverProxy"]))

        receiverView.frameAlignmentProxy.align(
            .bottomRight,
            with: targetView.frameAlignmentProxy,
            .bottomRight
        )
        updateMirrorViews()
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["bothProxies"]))
    }

}

// MARK: -

extension Position {

    var testDescription: String {
        switch self {
        case .topLeft:
            return "TopLeft"
        case .topCenter:
            return "TopCenter"
        case .topRight:
            return "TopRight"
        case .leftCenter:
            return "LeftCenter"
        case .center:
            return "Center"
        case .rightCenter:
            return "RightCenter"
        case .bottomLeft:
            return "BottomLeft"
        case .bottomCenter:
            return "BottomCenter"
        case .bottomRight:
            return "BottomRight"
        case .topLeading:
            return "TopLeading"
        case .topTrailing:
            return "TopTrailing"
        case .leadingCenter:
            return "LeadingCenter"
        case .trailingCenter:
            return "TrailingCenter"
        case .bottomLeading:
            return "BottomLeading"
        case .bottomTrailing:
            return "BottomTrailing"
        }
    }

}

// MARK: -

private final class LayoutMarginsView: UIView {

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(insetView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Properties

    let insetView: UIView = .init()

    // MARK: - UIView

    override func layoutSubviews() {
        insetView.frame = bounds.inset(by: layoutMargins)
    }

}
