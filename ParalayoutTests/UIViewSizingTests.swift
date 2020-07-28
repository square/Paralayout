//
//  UIViewSizingTests.swift
//  ParalayoutTests
//
//  Created by Nicholas Entin on 7/27/20.
//  Copyright © 2020 Square, Inc. All rights reserved.
//

import Paralayout
import XCTest

final class UIViewSizingTests: XCTestCase {

    // MARK: - Tests

    func testFrameSizeWithNoConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .zero),
            .init(width: 300, height: 200)
        )
    }

    func testFrameSizeWithMaxWidthConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .init(width: 150, height: 100), constraints: .maxWidth),
            .init(width: 150, height: 200)
        )
    }

    func testFrameSizeWithMaxHeightConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .init(width: 150, height: 100), constraints: .maxHeight),
            .init(width: 300, height: 100)
        )
    }

    func testFrameSizeWithMaxSizeConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .init(width: 150, height: 100), constraints: .maxSize),
            .init(width: 150, height: 100)
        )
    }

    func testFrameSizeWithMinWidthConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .init(width: 500, height: 400), constraints: .minWidth),
            .init(width: 500, height: 200)
        )
    }

    func testFrameSizeWithMinHeightConstraints() {
        let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

        XCTAssertEqual(
            testView.frameSize(thatFits: .init(width: 500, height: 400), constraints: .minHeight),
            .init(width: 300, height: 400)
        )
    }

    func testFrameSizeWithMinSizeConstraints() {
           let testView = TestView(sizeThatFits: .init(width: 300, height: 200))

           XCTAssertEqual(
               testView.frameSize(thatFits: .init(width: 500, height: 400), constraints: .minSize),
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
