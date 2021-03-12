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

final class InterpolationTests: XCTestCase {

    func testCGRectInterpolation() {
        let startRect = CGRect(x: 1, y: 2, width: 5, height: 6)
        let endRect = CGRect(x: 3, y: 4, width: 7, height: 8)
        let actualRect = Interpolation.middle.interpolate(from: startRect, to: endRect)
        let expectedRect = CGRect(origin: CGPoint(x: 2, y: 3), size: CGSize(width: 6, height: 7))

        XCTAssertEqual(actualRect, expectedRect)
    }

}
