//
//  Copyright © 2024 Block, Inc.
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

#if swift(>=5.4)
final class ViewArrayBuilderTests: XCTestCase {

    // MARK: - Tests

    func testSimpleResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        XCTAssertEqual(
            viewArray {
                view1
                view2
            },
            [
                view1,
                view2,
            ]
        )
    }

    func testIfTrueResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let condition = true
        XCTAssertEqual(
            viewArray {
                view1
                if condition {
                    view2
                }
                view3
            },
            [
                view1,
                view2,
                view3,
            ]
        )
    }

    func testIfFalseResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let condition = false
        XCTAssertEqual(
            viewArray {
                view1
                if condition {
                    view2
                }
                view3
            },
            [
                view1,
                view3,
            ]
        )
    }

    func testIfElseFirstBranchResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let view4 = UIView()
        let condition = true
        XCTAssertEqual(
            viewArray {
                view1
                if condition {
                    view2
                } else {
                    view3
                }
                view4
            },
            [
                view1,
                view2,
                view4,
            ]
        )
    }

    func testIfElseSecondBranchResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let view4 = UIView()
        let condition = false
        XCTAssertEqual(
            viewArray {
                view1
                if condition {
                    view2
                } else {
                    view3
                }
                view4
            },
            [
                view1,
                view3,
                view4,
            ]
        )
    }

    func testSwitchCaseResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let value = 1
        XCTAssertEqual(
            viewArray {
                view1
                switch value {
                case 1:
                    view2
                default:
                    nil
                }
                view3
            },
            [
                view1,
                view2,
                view3,
            ]
        )
    }

    func testSwitchDefaultResultBuilder() throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let value = 2
        XCTAssertEqual(
            viewArray {
                view1
                switch value {
                case 1:
                    view2
                default:
                    nil
                }
                view3
            },
            [
                view1,
                view3,
            ]
        )
    }

    func testForLoopResultBuilder() throws {
        let views = [UIView(), UIView(), UIView()]
        XCTAssertEqual(
            viewArray {
                for view in views {
                    view
                }
            },
            views
        )
    }

    // MARK: - Private Methods

    private func viewArray(@ViewArrayBuilder _ builder: () -> [UIView]) -> [UIView] {
        builder()
    }
}
#endif
