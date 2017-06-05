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


class AspectRatioTests: XCTestCase {
    
    func testStatics() {
        XCTAssert(AspectRatio.square.height(forWidth: 1, in: 0) == 1)
        XCTAssert(AspectRatio.square.width(forHeight: 1, in: 0) == 1)
        XCTAssert(AspectRatio.square.height(forWidth: 7, in: 0) == 7)
        XCTAssert(AspectRatio.square.width(forHeight: 7, in: 0) == 7)
        
        XCTAssert(AspectRatio.golden.width(forHeight: 1, in: 0) == (CGFloat(1) + sqrt(5)) / 2)
        
        XCTAssert(AspectRatio.widescreen.width(forHeight: 9, in: 0) == 16)
        XCTAssert(AspectRatio.widescreen.height(forWidth: 16, in: 0) == 9)
    }
    
    func testCreation() {
        XCTAssert(AspectRatio(width: 1, height: 1) == AspectRatio.square)
        XCTAssert(AspectRatio(width: 2, height: 2) == AspectRatio.square)
        
        XCTAssert(AspectRatio(size: CGSize(width: 4, height: 4)) == AspectRatio.square)
        XCTAssert(CGSize(width: 4, height: 4).aspectRatio == AspectRatio.square)
        
        XCTAssert(AspectRatio(rect: CGRect(x: 0, y: 0, width: 100, height: 100)) == AspectRatio.square)
        XCTAssert(CGRect(x: 25, y: 50, width: 100, height: 100).aspectRatio == AspectRatio.square)
    }
    
    func testInverted() {
        XCTAssert(AspectRatio.square.inverted == AspectRatio.square)
        XCTAssert(AspectRatio(width: 100, height: 50).inverted == AspectRatio(width: 5, height: 10))
        
        XCTAssert(AspectRatio.golden.inverted.height(forWidth: 1, in: 0) == (CGFloat(1) + sqrt(5)) / 2)
        
        XCTAssert(AspectRatio.widescreen.inverted.width(forHeight: 16, in: 0) == 9)
        XCTAssert(AspectRatio.widescreen.inverted.height(forWidth: 9, in: 0) == 16)
    }
    
    func testComparison() {
        // Aspect ratios in sorted order.
        let ratios = [AspectRatio.widescreen.inverted,
                      AspectRatio.golden.inverted,
                      AspectRatio.square,
                      AspectRatio.golden,
                      AspectRatio.widescreen]
        
        for i in 0..<ratios.count {
            for j in 0..<ratios.count {
                let ratio_i = ratios[i]
                let ratio_j = ratios[j]
                
                // Each ratio should compare the same as the indexes do.
                XCTAssert((i == j) == (ratio_i == ratio_j))
                XCTAssert((i <  j) == (ratio_i <  ratio_j))
                XCTAssert((i <= j) == (ratio_i <= ratio_j))
                XCTAssert((i >= j) == (ratio_i >= ratio_j))
                XCTAssert((i >  j) == (ratio_i >  ratio_j))
            }
        }
    }
    
    func testSizes() {
        // The core sizing methods round the resulting dimension.
        XCTAssert(AspectRatio.square.width(forHeight: 10.5, in: 1) == 11)
        XCTAssert(AspectRatio.square.width(forHeight: 10.5, in: 2) == 10.5)
        XCTAssert(AspectRatio.square.width(forHeight: 10.25, in: 2) == 10.5)
        XCTAssert(AspectRatio.square.width(forHeight: 10.24, in: 2) == 10)
        
        XCTAssert(AspectRatio.golden.width(forHeight: 1_000_000, in: 1) == 1_618_034)
        XCTAssert(AspectRatio.golden.height(forWidth: 1_618_034, in: 1) == 1_000_000)
        
        // Every size method should preserve the input in the correct dimension
        for ratio in [AspectRatio.square, AspectRatio.golden, AspectRatio.widescreen] {
            for input: CGFloat in [0.5, 1, 10, 240] {
                XCTAssert(ratio.width(forHeight: input, in: 0) == ratio.size(forHeight: input, in: 0).width)
                XCTAssert(ratio.height(forWidth: input, in: 0) == ratio.size(forWidth: input, in: 0).height)
            }
        }
    }
    
    func testRects() {
        // Use a set of rectangles with varying aspect ratios (square, landscape, portrait; origin offsets; non-integral)
        let rectangles = [ CGRect(x: 20, y: 18, width: 100, height: 100),
                           CGRect(x: 10, y:  0, width: 300, height: 100),
                           CGRect(x:  0, y: 75, width:  50, height:  20),
                           CGRect(origin: .zero, size: AspectRatio.square.size(forWidth: 640, in: 0)),
                           CGRect(origin: .zero, size: AspectRatio.widescreen.size(forWidth: 1334, in: 0)),
                           CGRect(origin: .zero, size: AspectRatio.golden.size(forWidth: 1000, in: 0))
                           ]
        
        let aspectRatios = rectangles.map() { $0.aspectRatio }
        let scaleFactors: [CGFloat] = [ 0, 1, 2, 3 ]
        let positions: [Position] = [ .topLeft, .topCenter, .topRight, .leftCenter, .center, .rightCenter, .bottomLeft, .bottomCenter, .bottomRight ]
        
        for ratio in aspectRatios {
            for rectangle in rectangles {
                for scale in scaleFactors {
                    for position in positions {
                        // Make sure the source rectangle matches the scale factor we're testing.
                        let rect = rectangle.expandToPixel(scale)
                        
                        // Rect/size to fit.
                        let rectToFit = ratio.rect(toFit: rect, at: position, in: scale)
                        XCTAssert(rectToFit.size == ratio.size(toFit: rect.size, in: scale))
                        
                        // The rect needs to be positioned as requested (within a pixel).
                        let rectToFitOffset = position.point(in: rectToFit) - position.point(in: rect)
                        XCTAssert(rectToFitOffset.horizontal * scale < 1 && rectToFitOffset.vertical * scale < 1)
                        
                        if rectToFit.width == rect.width {
                            // It has to fit.
                            XCTAssert(rectToFit.height <= rect.height)
                            
                            // Its aspect ratio must match the source ratio's.
                            XCTAssert(rectToFit.height == ratio.height(forWidth: rectToFit.width, in: scale))
                            
                        } else {
                            // It has to fit.
                            XCTAssert(rectToFit.height == rect.height && rectToFit.width <= rect.width)
                            
                            // Its aspect ratio must match the source ratio's.
                            XCTAssert(rectToFit.width == ratio.width(forHeight: rectToFit.height, in: scale))
                        }
                        
                        
                        // Rect/size to fill.
                        let rectToFill = ratio.rect(toFill: rect, at: position, in: scale)
                        XCTAssert(rectToFill.size == ratio.size(toFill: rect.size, in: scale))
                        
                        // The rect needs to be positioned as requested (within a pixel).
                        let rectToFillOffset = position.point(in: rectToFill) - position.point(in: rect)
                        XCTAssert(rectToFillOffset.horizontal * scale < 1 && rectToFillOffset.vertical * scale < 1)
                        
                        if rectToFill.width == rect.width {
                            // It has to fill.
                            XCTAssert(rectToFill.height >= rect.height)
                            
                            // Its aspect ratio must match the source ratio's.
                            XCTAssert(rectToFill.height == ratio.height(forWidth: rectToFill.width, in: scale))
                            
                        } else {
                            // It has to fill.
                            XCTAssert(rectToFill.height == rect.height && rectToFill.width >= rect.width)
                            
                            // Its aspect ratio must match the source ratio's.
                            XCTAssert(rectToFill.width == ratio.width(forHeight: rectToFill.height, in: scale))
                        }
                    }
                }
            }
        }
    }
    
}
