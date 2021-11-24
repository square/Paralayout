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

    func testDistribution() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        containerView.backgroundColor = .white

        let secondView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        secondView.backgroundColor = .blue
        containerView.addSubview(secondView)

        let firstView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        firstView.backgroundColor = .red
        containerView.addSubview(firstView)

        let thirdView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 10))
        thirdView.backgroundColor = .green
        containerView.addSubview(thirdView)

        containerView.applySubviewDistribution(
            [
                firstView,
                secondView,
                thirdView,
            ]
        )
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: ["vertical"]))
    }

    func testDistributionIgnoresTransform() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        containerView.backgroundColor = .white

        let secondView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        secondView.backgroundColor = .blue
        secondView.transform = CGAffineTransform(scaleX: 3, y: 3).rotated(by: .pi / 3)
        containerView.addSubview(secondView)

        let firstView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        firstView.backgroundColor = .red
        containerView.addSubview(firstView)

        let thirdView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 10))
        thirdView.backgroundColor = .green
        containerView.addSubview(thirdView)

        containerView.applySubviewDistribution(
            [
                firstView,
                secondView,
                thirdView,
            ]
        )
        assertSnapshot(matching: containerView, as: .image, named: nameForSnapshot(with: []))
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
