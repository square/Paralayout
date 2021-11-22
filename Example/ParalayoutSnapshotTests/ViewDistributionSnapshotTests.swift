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

final class ViewDistributionSnapshotTests: SnapshotTestCase {

    func testSpreadSubviews() {
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
            axis: ViewDistributionAxis = .horizontal,
            margin: CGFloat = 0,
            inRect rect: CGRect? = nil,
            orthogonalBehavior: ViewSpreadingBehavior = .fill,
            layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            redView.frame = .init(x: 0, y: 0, width: 100, height: 30)
            blueView.frame = .init(x: 0, y: 0, width: 50, height: 20)
            greenView.frame = .init(x: 0, y: 0, width: 70, height: 40)

            container.semanticContentAttribute = .attributeToForce(layoutDirection)
            container.spreadOutSubviews(
                [redView, blueView, greenView],
                axis: axis,
                margin: margin,
                inRect: rect,
                orthogonalBehavior: orthogonalBehavior
            )

            assertSnapshot(
                matching: container,
                as: .image,
                named: nameForSnapshot(
                    with: [
                        axis.testDescription,
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
        verifySnapshot(orthogonalBehavior: .leading(inset: 0))
        verifySnapshot(orthogonalBehavior: .leading(inset: 10))
        verifySnapshot(orthogonalBehavior: .trailing(inset: 0))
        verifySnapshot(orthogonalBehavior: .trailing(inset: 10))
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50), orthogonalBehavior: .centered(offset: 0))

        // Verify vertical layout.
        verifySnapshot(axis: .vertical)
        verifySnapshot(axis: .vertical, inRect: CGRect(x: 20, y: 10, width: 300, height: 50))

        // Verify orthogonal behaviors in vertical LTR layout.
        verifySnapshot(axis: .vertical, orthogonalBehavior: .centered(offset: 0))
        verifySnapshot(axis: .vertical, orthogonalBehavior: .centered(offset: 50))
        verifySnapshot(axis: .vertical, orthogonalBehavior: .leading(inset: 0))
        verifySnapshot(axis: .vertical, orthogonalBehavior: .leading(inset: 10))
        verifySnapshot(axis: .vertical, orthogonalBehavior: .trailing(inset: 0))
        verifySnapshot(axis: .vertical, orthogonalBehavior: .trailing(inset: 10))
        verifySnapshot(
            axis: .vertical,
            inRect: CGRect(x: 20, y: 10, width: 300, height: 50),
            orthogonalBehavior: .centered(offset: 0)
        )

        // Verify orthogonal behaviors in vertical RTL layout.
        verifySnapshot(axis: .vertical, orthogonalBehavior: .centered(offset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, orthogonalBehavior: .centered(offset: 50), layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, orthogonalBehavior: .leading(inset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, orthogonalBehavior: .leading(inset: 10), layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, orthogonalBehavior: .trailing(inset: 0), layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, orthogonalBehavior: .trailing(inset: 10), layoutDirection: .rightToLeft)

        // Verify margins between subviews.
        verifySnapshot(margin: 40, layoutDirection: .leftToRight)
        verifySnapshot(margin: 40, layoutDirection: .rightToLeft)
        verifySnapshot(axis: .vertical, margin: 20)
        verifySnapshot(margin: 40, inRect: CGRect(x: 20, y: 10, width: 300, height: 50))
    }

}

// MARK: -

extension UISemanticContentAttribute {

    static func attributeToForce(_ layoutDirection: UIUserInterfaceLayoutDirection) -> UISemanticContentAttribute {
        switch layoutDirection {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        @unknown default:
            fatalError("Unknown layout direction")
        }
    }

}

// MARK: -

extension ViewDistributionAxis {

    var testDescription: String {
        switch self {
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        }
    }

}

extension UIUserInterfaceLayoutDirection {

    var testDescription: String {
        switch self {
        case .leftToRight:
            return "LTR"
        case .rightToLeft:
            return "RTL"
        @unknown default:
            fatalError("Unknown layout direction")
        }
    }

}

extension ViewSpreadingBehavior {

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
