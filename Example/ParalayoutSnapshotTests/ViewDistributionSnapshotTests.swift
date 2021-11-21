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
            sizeToBounds: Bool = true,
            layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight,
            file: StaticString = #file,
            testName: String = #function,
            line: UInt = #line
        ) {
            redView.frame = .init(x: 0, y: 0, width: 30, height: 30)
            blueView.frame = .init(x: 0, y: 0, width: 30, height: 30)
            greenView.frame = .init(x: 0, y: 0, width: 30, height: 30)

            container.semanticContentAttribute = .attributeToForce(layoutDirection)
            container.spreadOutSubviews(
                [redView, blueView, greenView],
                axis: axis,
                margin: margin,
                inRect: rect,
                sizeToBounds: sizeToBounds
            )

            assertSnapshot(
                matching: container,
                as: .image,
                named: nameForSnapshot(
                    with: [
                        axis.testDescription,
                        (margin != 0 ? "nonZeroMargin" : nil),
                        (rect != nil ? "inLayoutRect" : nil),
                        (!sizeToBounds ? "preserveSize" : nil),
                        layoutDirection.testDescription,
                    ]
                ),
                file: file,
                testName: testName,
                line: line
            )
        }

        verifySnapshot()
        verifySnapshot(inRect: CGRect(x: 20, y: 10, width: 300, height: 50))
    }

    func testDistributionUsingCapInsets() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        containerView.backgroundColor = .white

        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        topView.backgroundColor = .red
        containerView.addSubview(topView)

        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        bottomView.backgroundColor = .green
        containerView.addSubview(bottomView)

        let label = UILabel()
        label.text = "HÉLLÖ Worldy"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.sizeToFit()
        containerView.addSubview(label)

        containerView.applySubviewDistribution(
            [
                1.flexible,
                topView,
                label.distributionItemUsingCapInsets,
                bottomView,
                1.flexible,
            ]
        )

        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
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
