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

final class UIViewSizingTests: XCTestCase {

    // MARK: - Tests

    func testSizeThatFitsWithNoConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.zero),
            .init(width: 300, height: 200)
        )
    }

    func testSizeThatFitsWithMaxWidthConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 150, height: 100), constraints: .maxWidth),
            .init(width: 150, height: 200)
        )
    }

    func testSizeThatFitsWithMaxHeightConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 150, height: 100), constraints: .maxHeight),
            .init(width: 300, height: 100)
        )
    }

    func testSizeThatFitsWithMaxSizeConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 150, height: 100), constraints: .maxSize),
            .init(width: 150, height: 100)
        )
    }

    func testSizeThatFitsWithMinWidthConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 500, height: 400), constraints: .minWidth),
            .init(width: 500, height: 200)
        )
    }

    func testSizeThatFitsWithMinHeightConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 500, height: 400), constraints: .minHeight),
            .init(width: 300, height: 400)
        )
    }

    func testSizeThatFitsWithMinSizeConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.sizeThatFits(.init(width: 500, height: 400), constraints: .minSize),
            .init(width: 500, height: 400)
        )
    }

}

// MARK: -

private final class TestView: UIView {

    // MARK: - Life Cycle

    init(sizeThatFits: CGSize) {
        self.sizeThatFits = sizeThatFits

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private let sizeThatFits: CGSize

    // MARK: - UIView

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits
    }

}
