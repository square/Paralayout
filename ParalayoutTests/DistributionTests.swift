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
import XCTest
import UIKit

final class DistributionTests: XCTestCase {

    // MARK: - Tests - Orthogonal Alignment

    func testOrthogonalAlignmentInHorizontalDistribution() {
        // The layout direction shouldn't affect the orthogonal alignment in a horizontal distribution.
        for forcedLayoutDirection in [UISemanticContentAttribute.forceLeftToRight, .forceRightToLeft] {
            let container = UIView(frame: .init(x: 0, y: 0, width: 1000, height: 200))
            container.semanticContentAttribute = forcedLayoutDirection

            let firstSubview = UIView(frame: .init(x: 0, y: 0, width: 100, height: 50))
            container.addSubview(firstSubview)
            let secondSubview = UIView(frame: .init(x: 0, y: 0, width: 50, height: 100))
            container.addSubview(secondSubview)

            func test(
                alignment: VerticalDistributionAlignment?,
                inRect layoutRect: CGRect? = nil,
                testBlock: () -> Void
            ) {
                container.applyHorizontalSubviewDistribution(
                    [firstSubview, secondSubview],
                    inRect: layoutRect,
                    orthogonalAlignment: alignment
                )

                testBlock()
            }

            test(alignment: .centered(offset: 10)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 85)
                XCTAssertEqual(secondSubview.frame.origin.y, 60)
            }

            test(alignment: .top(inset: 10)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 10)
                XCTAssertEqual(secondSubview.frame.origin.y, 10)
            }

            test(alignment: .bottom(inset: 10)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 140)
                XCTAssertEqual(secondSubview.frame.origin.y, 90)
            }

            // An orthogonal alignment of `nil` should not mutate the subviews' alignment on the Y axis.
            firstSubview.frame.origin.y = -10
            secondSubview.frame.origin.y = 100
            test(alignment: nil) {
                XCTAssertEqual(firstSubview.frame.origin.y, -10)
                XCTAssertEqual(secondSubview.frame.origin.y, 100)
            }

            test(alignment: .centered(offset: 10), inRect: .init(x: 0, y: 1000, width: 1000, height: 300)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 1135)
                XCTAssertEqual(secondSubview.frame.origin.y, 1110)
            }

            test(alignment: .top(inset: 10), inRect: .init(x: 0, y: 1000, width: 1000, height: 300)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 1010)
                XCTAssertEqual(secondSubview.frame.origin.y, 1010)
            }

            test(alignment: .bottom(inset: 10), inRect: .init(x: 0, y: 1000, width: 1000, height: 300)) {
                XCTAssertEqual(firstSubview.frame.origin.y, 1240)
                XCTAssertEqual(secondSubview.frame.origin.y, 1190)
            }
        }
    }

    func testOrthogonalAlignmentInVerticalDistribution_leftToRightLayout() {
        let container = UIView(frame: .init(x: 0, y: 0, width: 200, height: 1000))
        container.semanticContentAttribute = .forceLeftToRight

        let firstSubview = UIView(frame: .init(x: 0, y: 0, width: 50, height: 100))
        container.addSubview(firstSubview)
        let secondSubview = UIView(frame: .init(x: 0, y: 0, width: 100, height: 50))
        container.addSubview(secondSubview)

        func test(
            alignment: HorizontalDistributionAlignment?,
            inRect layoutRect: CGRect? = nil,
            testBlock: () -> Void
        ) {
            container.applyVerticalSubviewDistribution(
                [firstSubview, secondSubview],
                inRect: layoutRect,
                orthogonalAlignment: alignment
            )

            testBlock()
        }

        test(alignment: .centered(offset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 85)
            XCTAssertEqual(secondSubview.frame.origin.x, 60)
        }

        test(alignment: .leading(inset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 10)
            XCTAssertEqual(secondSubview.frame.origin.x, 10)
        }

        test(alignment: .trailing(inset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 140)
            XCTAssertEqual(secondSubview.frame.origin.x, 90)
        }

        // An orthogonal alignment of `nil` should not mutate the subviews' alignment on the X axis.
        firstSubview.frame.origin.x = -10
        secondSubview.frame.origin.x = 100
        test(alignment: nil) {
            XCTAssertEqual(firstSubview.frame.origin.x, -10)
            XCTAssertEqual(secondSubview.frame.origin.x, 100)
        }

        test(alignment: .centered(offset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1135)
            XCTAssertEqual(secondSubview.frame.origin.x, 1110)
        }

        test(alignment: .leading(inset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1010)
            XCTAssertEqual(secondSubview.frame.origin.x, 1010)
        }

        test(alignment: .trailing(inset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1240)
            XCTAssertEqual(secondSubview.frame.origin.x, 1190)
        }
    }

    func testOrthogonalAlignmentInVerticalDistribution_rightToLeftLayout() {
        let container = UIView(frame: .init(x: 0, y: 0, width: 200, height: 1000))
        container.semanticContentAttribute = .forceRightToLeft

        let firstSubview = UIView(frame: .init(x: 0, y: 0, width: 50, height: 100))
        container.addSubview(firstSubview)
        let secondSubview = UIView(frame: .init(x: 0, y: 0, width: 100, height: 50))
        container.addSubview(secondSubview)

        func test(
            alignment: HorizontalDistributionAlignment?,
            inRect layoutRect: CGRect? = nil,
            testBlock: () -> Void
        ) {
            container.applyVerticalSubviewDistribution(
                [firstSubview, secondSubview],
                inRect: layoutRect,
                orthogonalAlignment: alignment
            )

            testBlock()
        }

        test(alignment: .centered(offset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 65)
            XCTAssertEqual(secondSubview.frame.origin.x, 40)
        }

        test(alignment: .leading(inset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 140)
            XCTAssertEqual(secondSubview.frame.origin.x, 90)
        }

        test(alignment: .trailing(inset: 10)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 10)
            XCTAssertEqual(secondSubview.frame.origin.x, 10)
        }

        // An orthogonal alignment of `nil` should not mutate the subviews' alignment on the X axis.
        firstSubview.frame.origin.x = -10
        secondSubview.frame.origin.x = 100
        test(alignment: nil) {
            XCTAssertEqual(firstSubview.frame.origin.x, -10)
            XCTAssertEqual(secondSubview.frame.origin.x, 100)
        }

        test(alignment: .centered(offset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1115)
            XCTAssertEqual(secondSubview.frame.origin.x, 1090)
        }

        test(alignment: .leading(inset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1240)
            XCTAssertEqual(secondSubview.frame.origin.x, 1190)
        }

        test(alignment: .trailing(inset: 10), inRect: .init(x: 1000, y: 0, width: 300, height: 1000)) {
            XCTAssertEqual(firstSubview.frame.origin.x, 1010)
            XCTAssertEqual(secondSubview.frame.origin.x, 1010)
        }
    }

}
