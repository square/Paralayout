//
//  Copyright © 2017 Square, Inc.
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

final class GeometryAdditionsTests: XCTestCase {

    // MARK: - Tests - Operators
    
    func testOffsetOperators() {
        // Combine offsets.
        XCTAssertEqual(
            UIOffset(horizontal: 12, vertical: 8) + .zero,
            UIOffset(horizontal: 12, vertical: 8)
        )
        XCTAssertEqual(
            UIOffset(horizontal: 12, vertical: 8) + UIOffset(horizontal: 12, vertical: 8),
            UIOffset(horizontal: 24, vertical: 16)
        )
        XCTAssertEqual(
            UIOffset(horizontal: 12, vertical: 8) * 2,
            UIOffset(horizontal: 24, vertical: 16)
        )
        XCTAssertEqual(
            UIOffset(horizontal: 12, vertical: 8) / 4,
            UIOffset(horizontal:  3, vertical: 2)
        )
        
        // Apply and derive offsets.
        XCTAssertEqual(
            CGPoint.zero + UIOffset(horizontal: 12, vertical: 8),
            CGPoint(x: 12, y: 8)
        )
        XCTAssertEqual(
            CGPoint(x: -4, y: -10) + UIOffset(horizontal: 12, vertical: 8),
            CGPoint(x: 8, y: -2)
        )
        XCTAssertEqual(
            CGRect(x: 20, y: 20, width: 100, height: 100) + UIOffset(horizontal: 10, vertical: 0),
            CGRect(x: 30, y: 20, width: 100, height: 100)
        )
        XCTAssertEqual(
            CGPoint(x: 50, y: 20) - CGPoint(x: 40, y: 20),
            UIOffset(horizontal: 10, vertical: 0)
        )
    }

    // MARK: - Tests - CGPoint Extensions

    func testMidpoint() {
        // The midpoint between two of the same point should be that point.
        XCTAssertEqual(CGPoint(midpointBetween: .zero, and: .zero), .zero)
        XCTAssertEqual(CGPoint(midpointBetween: .init(x: 20, y: 40), and: .init(x: 20, y: 40)), .init(x: 20, y: 40))

        XCTAssertEqual(
            CGPoint(midpointBetween: .init(x: 20, y: 30), and: .init(x: 10, y: 70)),
            .init(x: 15, y: 50)
        )
        XCTAssertEqual(
            CGPoint(midpointBetween: .init(x: -20, y: 30), and: .init(x: 10, y: -70)),
            .init(x: -5, y: -20)
        )
        XCTAssertEqual(
            CGPoint(midpointBetween: .init(x: -20, y: -30), and: .init(x: -10, y: -70)),
            .init(x: -15, y: -50)
        )
    }

    func testDistanceBetweenPoints() {
        // A point's distance from itself is always zero.
        XCTAssertEqual(CGPoint.zero.distance(to: .zero), 0)
        XCTAssertEqual(CGPoint(x: 20, y: -30).distance(to: .init(x: 20, y: -30)), 0)

        // Test along all of the +/- x/y axes.
        XCTAssertEqual(CGPoint.zero.distance(to: .init(x: 0, y: 10)), 10)
        XCTAssertEqual(CGPoint.zero.distance(to: .init(x: 10, y: 0)), 10)
        XCTAssertEqual(CGPoint.zero.distance(to: .init(x: 0, y: -10)), 10)
        XCTAssertEqual(CGPoint.zero.distance(to: .init(x: -10, y: 0)), 10)

        XCTAssertEqual(CGPoint(x: -10, y: 10).distance(to: .init(x: -12, y: 12)), 2 * sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(CGPoint(x: 10, y: 10).distance(to: .init(x: 11, y: 11)), sqrt(2), accuracy: 1e-10)
    }

    // MARK: - Tests - CGRect Extensions
    
    func testCGRectCreation() {
        XCTAssertEqual(CGRect(left: 10, top: 10, right: 50, bottom: 50), CGRect(x: 10, y: 10, width: 40, height: 40))
        XCTAssertEqual(CGRect(left: 50, top: 50, right: 10, bottom: 10), CGRect(x: 10, y: 10, width: 40, height: 40))
    }

    func testCGRectInset() {
        // CGRect.insetBy(left:top:right:bottom:)
        XCTAssertEqual(
            CGRect(x: 10, y: 10, width: 40, height: 40).insetBy(left: 5, top: 10, right: 0, bottom: 15),
            CGRect(x: 15, y: 20, width: 35, height: 15)
        )
        XCTAssertEqual(
            CGRect(x: 10, y: 10, width: 40, height: 40).insetBy(top: 10),
            CGRect(x: 10, y: 20, width: 40, height: 30)
        )
        XCTAssertEqual(
            CGRect(x: 10, y: 10, width: 40, height: 40).insetBy(left: -10),
            CGRect(x: 0, y: 10, width: 50, height: 40)
        )

        // CGRect.insetAllSides(by:)
        XCTAssertEqual(
            CGRect(x: 10, y: 20, width: 30, height: 40).insetAllSides(by: 5),
            CGRect(x: 15, y: 25, width: 20, height: 30)
        )
        XCTAssertEqual(
            CGRect(x: 10, y: 20, width: 30, height: 40).insetAllSides(by: -5),
            CGRect(x: 5, y: 15, width: 40, height: 50)
        )

        // CGRect.outset(by:)
        XCTAssertEqual(
            CGRect(x: 10, y: 20, width: 30, height: 40).outset(by: .init(top: 1, left: 2, bottom: 3, right: 4)),
            CGRect(x: 8, y: 19, width: 36, height: 44)
        )
        XCTAssertEqual(
            CGRect(x: 10, y: 20, width: 30, height: 40).outset(by: .zero),
            CGRect(x: 10, y: 20, width: 30, height: 40)
        )
    }
    
    func testCGRectSlice() {
        // CGRect.zero tests
        XCTAssert(CGRect.zero.slice(from: .minXEdge, amount: 0) == (.zero, .zero))
        XCTAssert(CGRect.zero.slice(from: .maxXEdge, amount: 0) == (.zero, .zero))
        XCTAssert(CGRect.zero.slice(from: .minYEdge, amount: 0) == (.zero, .zero))
        XCTAssert(CGRect.zero.slice(from: .maxYEdge, amount: 0) == (.zero, .zero))
        
        let sample = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // 0-sized slices.
        XCTAssert(sample.slice(from: .minXEdge, amount: 0).remainder == sample)
        XCTAssert(sample.slice(from: .maxXEdge, amount: 0).remainder == sample)
        XCTAssert(sample.slice(from: .minYEdge, amount: 0).remainder == sample)
        XCTAssert(sample.slice(from: .maxYEdge, amount: 0).remainder == sample)
        
        XCTAssert(sample.slice(from: .minXEdge, amount: 0).slice == CGRect(x: 0,   y: 0,   width: 0,   height: 100))
        XCTAssert(sample.slice(from: .maxXEdge, amount: 0).slice == CGRect(x: 100, y: 0,   width: 0,   height: 100))
        XCTAssert(sample.slice(from: .minYEdge, amount: 0).slice == CGRect(x: 0,   y: 0,   width: 100, height: 0))
        XCTAssert(sample.slice(from: .maxYEdge, amount: 0).slice == CGRect(x: 0,   y: 100, width: 100, height: 0))
        
        // Non-0 slices.
        XCTAssert(sample.slice(from: .minXEdge, amount:  10) == (CGRect(x:  0,   y:  0, width:  10, height: 100),
                                                                 CGRect(x: 10,   y:  0, width:  90, height: 100)))
        
        XCTAssert(sample.slice(from: .maxXEdge, amount:  50) == (CGRect(x: 50,   y:  0, width:  50, height: 100),
                                                                 CGRect(x:  0,   y:  0, width:  50, height: 100)))
        
        XCTAssert(sample.slice(from: .minYEdge, amount:  70) == (CGRect(x:  0,   y:  0, width: 100, height:  70),
                                                                 CGRect(x:  0,   y: 70, width: 100, height:  30)))
        
        XCTAssert(sample.slice(from: .maxYEdge, amount: 100) == (sample,
                                                                 CGRect(x:  0,   y:  0, width: 100, height:   0)))
    }
    
}
