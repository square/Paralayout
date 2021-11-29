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

final class ViewSpeadingSnapshotTests: SnapshotTestCase {

    func testHorizontallySpreadSubviews() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        container.backgroundColor = .white

        let redView = UIView()
        redView.backgroundColor = .red
        container.addSubview(redView)

        let blueView = UIView()
        blueView.backgroundColor = .blue
        container.addSubview(blueView)

        let greenView = UIView()
        greenView.backgroundColor = .green
        container.addSubview(greenView)

        func verifySnapshot(
            margin: CGFloat = 0,
            inRect rect: CGRect? = nil,
            orthogonalBehavior: VerticalSpreadingBehavior = .fill,
            layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            redView.frame = .init(x: 0, y: 0, width: 100, height: 30)
            blueView.frame = .init(x: 0, y: 0, width: 50, height: 20)
            greenView.frame = .init(x: 0, y: 0, width: 70, height: 40)

            container.semanticContentAttribute = .attributeToForce(layoutDirection)
            container.horizontallySpreadSubviews(
                [redView, blueView, greenView],
                margin: margin,
                inRect: rect,
                orthogonalBehavior: orthogonalBehavior
            )

            assertSnapshot(
                matching: container,
                as: .image,
                named: nameForSnapshot(
                    with: [
                        (margin != 0 ? "nonZeroMargin" : nil),
                        (rect != nil ? "inLayoutRect" : nil),
                        orthogonalBehavior.testDescription,
                        layoutDirection.testDescription,
                    ]
                ),
                file: file,
                testName: testName,
                line: line
            )
        }

        verifySnapshot()
        verifySnapshot(layoutDirection: .rightToLeft)
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50))

        // Verify orthogonal behaviors in horizontal layout.
        verifySnapshot(orthogonalBehavior: .centered(offset: 0))
        verifySnapshot(orthogonalBehavior: .centered(offset: 20))
        verifySnapshot(orthogonalBehavior: .top(inset: 0))
        verifySnapshot(orthogonalBehavior: .top(inset: 10))
        verifySnapshot(orthogonalBehavior: .bottom(inset: 0))
        verifySnapshot(orthogonalBehavior: .bottom(inset: 10))
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50), orthogonalBehavior: .centered(offset: 0))

        // Verify margins between subviews.
        verifySnapshot(margin: 40, layoutDirection: .leftToRight)
        verifySnapshot(margin: 40, layoutDirection: .rightToLeft)
        verifySnapshot(margin: 40, inRect: CGRect(x: 20, y: 10, width: 300, height: 50))
    }

    func testVerticallySpreadSubviews() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        container.backgroundColor = .white

        let redView = UIView()
        redView.backgroundColor = .red
        container.addSubview(redView)

        let blueView = UIView()
        blueView.backgroundColor = .blue
        container.addSubview(blueView)

        let greenView = UIView()
        greenView.backgroundColor = .green
        container.addSubview(greenView)

        func verifySnapshot(
            margin: CGFloat = 0,
            inRect rect: CGRect? = nil,
            orthogonalBehavior: HorizontalSpreadingBehavior = .fill,
            layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            redView.frame = .init(x: 0, y: 0, width: 100, height: 30)
            blueView.frame = .init(x: 0, y: 0, width: 50, height: 20)
            greenView.frame = .init(x: 0, y: 0, width: 70, height: 40)

            container.semanticContentAttribute = .attributeToForce(layoutDirection)
            container.verticallySpreadSubviews(
                [redView, blueView, greenView],
                margin: margin,
                inRect: rect,
                orthogonalBehavior: orthogonalBehavior
            )

            assertSnapshot(
                matching: container,
                as: .image,
                named: nameForSnapshot(
                    with: [
                        (margin != 0 ? "nonZeroMargin" : nil),
                        (rect != nil ? "inLayoutRect" : nil),
                        orthogonalBehavior.testDescription,
                        layoutDirection.testDescription,
                    ]
                ),
                file: file,
                testName: testName,
                line: line
            )
        }

        // Verify vertical layout.
        verifySnapshot()
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50))

        // Verify orthogonal behaviors in vertical LTR layout.
        verifySnapshot(orthogonalBehavior: .centered(offset: 0))
        verifySnapshot(orthogonalBehavior: .centered(offset: 50))
        verifySnapshot(orthogonalBehavior: .leading(inset: 0))
        verifySnapshot(orthogonalBehavior: .leading(inset: 10))
        verifySnapshot(orthogonalBehavior: .trailing(inset: 0))
        verifySnapshot(orthogonalBehavior: .trailing(inset: 10))
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50), orthogonalBehavior: .centered(offset: 0))

        // Verify orthogonal behaviors in vertical RTL layout.
        verifySnapshot(orthogonalBehavior: .centered(offset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(orthogonalBehavior: .centered(offset: 50), layoutDirection: .rightToLeft)
        verifySnapshot(orthogonalBehavior: .leading(inset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(orthogonalBehavior: .leading(inset: 10), layoutDirection: .rightToLeft)
        verifySnapshot(orthogonalBehavior: .trailing(inset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(orthogonalBehavior: .trailing(inset: 10), layoutDirection: .rightToLeft)

        // Verify margins between subviews.
        verifySnapshot(margin: 20)
    }

}

// MARK: -

extension VerticalSpreadingBehavior {

    var testDescription: String? {
        switch self {
        case .fill:
            return nil
        case let .top(inset) where inset < 0:
            return "topWithNegativeInset"
        case let .top(inset) where inset > 0:
            return "topWithPositiveInset"
        case .top:
            return "top"
        case let .centered(offset) where offset < 0:
            return "centeredWithNegativeOffset"
        case let .centered(offset) where offset > 0:
            return "centeredWithPositiveOffset"
        case .centered:
            return "centered"
        case let .bottom(inset) where inset < 0:
            return "bottomWithNegativeInset"
        case let .bottom(inset) where inset > 0:
            return "bottomWithPositiveInset"
        case .bottom:
            return "bottom"
        }
    }

}

extension HorizontalSpreadingBehavior {

    var testDescription: String? {
        switch self {
        case .fill:
            return nil
        case let .leading(inset) where inset < 0:
            return "leadingWithNegativeInset"
        case let .leading(inset) where inset > 0:
            return "leadingWithPositiveInset"
        case .leading:
            return "leading"
        case let .centered(offset) where offset < 0:
            return "centeredWithNegativeOffset"
        case let .centered(offset) where offset > 0:
            return "centeredWithPositiveOffset"
        case .centered:
            return "centered"
        case let .trailing(inset) where inset < 0:
            return "trailingWithNegativeInset"
        case let .trailing(inset) where inset > 0:
            return "trailingWithPositiveInset"
        case .trailing:
            return "trailing"
        }
    }

}
