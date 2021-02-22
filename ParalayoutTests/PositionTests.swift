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

import XCTest

@testable import Paralayout

final class PositionTests: XCTestCase {

    func testResolvePositionsInLeftToRightLayout() {
        func resolve(_ position: Position) -> ResolvedPosition {
            return ResolvedPosition(resolving: position, with: .leftToRight)
        }

        // The direction agnostic positions are trivial.
        XCTAssertEqual(resolve(.topLeft), .topLeft)
        XCTAssertEqual(resolve(.topCenter), .topCenter)
        XCTAssertEqual(resolve(.topRight), .topRight)
        XCTAssertEqual(resolve(.leftCenter), .leftCenter)
        XCTAssertEqual(resolve(.center), .center)
        XCTAssertEqual(resolve(.rightCenter), .rightCenter)
        XCTAssertEqual(resolve(.bottomLeft), .bottomLeft)
        XCTAssertEqual(resolve(.bottomCenter), .bottomCenter)
        XCTAssertEqual(resolve(.bottomRight), .bottomRight)

        // The leading edge is on the left. The trailing edge is on the right.
        XCTAssertEqual(resolve(.topLeading), .topLeft)
        XCTAssertEqual(resolve(.topTrailing), .topRight)
        XCTAssertEqual(resolve(.leadingCenter), .leftCenter)
        XCTAssertEqual(resolve(.trailingCenter), .rightCenter)
        XCTAssertEqual(resolve(.bottomLeading), .bottomLeft)
        XCTAssertEqual(resolve(.bottomTrailing), .bottomRight)
    }

    func testResolvePositionsInRightToLeftLayout() {
        func resolve(_ position: Position) -> ResolvedPosition {
            return ResolvedPosition(resolving: position, with: .rightToLeft)
        }

        // The direction agnostic positions are trivial.
        XCTAssertEqual(resolve(.topLeft), .topLeft)
        XCTAssertEqual(resolve(.topCenter), .topCenter)
        XCTAssertEqual(resolve(.topRight), .topRight)
        XCTAssertEqual(resolve(.leftCenter), .leftCenter)
        XCTAssertEqual(resolve(.center), .center)
        XCTAssertEqual(resolve(.rightCenter), .rightCenter)
        XCTAssertEqual(resolve(.bottomLeft), .bottomLeft)
        XCTAssertEqual(resolve(.bottomCenter), .bottomCenter)
        XCTAssertEqual(resolve(.bottomRight), .bottomRight)

        // The leading edge is on the right. The trailing edge is on the left.
        XCTAssertEqual(resolve(.topLeading), .topRight)
        XCTAssertEqual(resolve(.topTrailing), .topLeft)
        XCTAssertEqual(resolve(.leadingCenter), .rightCenter)
        XCTAssertEqual(resolve(.trailingCenter), .leftCenter)
        XCTAssertEqual(resolve(.bottomLeading), .bottomRight)
        XCTAssertEqual(resolve(.bottomTrailing), .bottomLeft)
    }

}
