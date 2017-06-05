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


class HairlineTests: XCTestCase {
    
    enum Samples {
        static let window = UIWindow()
        static let view = UIView()
        static let hairline = Hairline()
    }
    
    override func setUp() {
        Samples.window.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        Samples.view.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        Samples.window.addSubview(Samples.view)
        Samples.view.addSubview(Samples.hairline)
        
        Samples.hairline.isHorizontal = true
        Samples.hairline.autoresizingMask = []
    }
    
    func testWidths() {
        // Test standard display resolutions.
        XCTAssert(TestScreen.at1x.hairlineWidth == 1)
        XCTAssert(TestScreen.at2x.hairlineWidth == 0.5)
        XCTAssert(TestScreen.at3x.hairlineWidth == (CGFloat(1) / 3))
        
        // Native width is 1/2 point.
        XCTAssert(UIScreen.hairlineWidth(for: 0) == 0.5)
        
        // A hypothetical 4x display should have 2px (not 1px) hairlines.
        XCTAssert(UIScreen.hairlineWidth(for: 4) == 0.5)
        
        // Windows/views should inherit the scale of the screen they're on.
        for screen in TestScreen.all {
            Samples.window.screen = screen
            XCTAssert(Samples.window.hairlineWidth == screen.hairlineWidth)
            XCTAssert(Samples.view.hairlineWidth == screen.hairlineWidth)
        }
    }
    
    func testNewInSuperview() {
        // Left, 3x, inset, with mask.
        Samples.window.screen = TestScreen.at3x
        let leftHairline = Hairline.new(in: Samples.window, at: .minXEdge, inset: 10, autoresize: true)
        XCTAssert(leftHairline.frame == CGRect(x: 0, y: 10, width: CGFloat(1) / 3, height: 30))
        XCTAssert(leftHairline.autoresizingMask == [ .flexibleHeight, .flexibleRightMargin ])
        XCTAssert(!leftHairline.isHorizontal)
        
        // Top, 2x, no inset, no resizing mask.
        Samples.window.screen = TestScreen.at2x
        let topHairline = Hairline.new(in: Samples.window, at: .minYEdge)
        XCTAssert(topHairline.frame == CGRect(x: 0, y: 0, width: 100, height: 0.5))
        XCTAssert(topHairline.autoresizingMask == [])
        XCTAssert(topHairline.isHorizontal)
        
        // Right, 2x, inset, no mask.
        Samples.window.screen = TestScreen.at2x
        let rightHairline = Hairline.new(in: Samples.window, at: .maxXEdge, inset: -5, autoresize: false)
        XCTAssert(rightHairline.frame == CGRect(x: 99.5, y: -5, width: 0.5, height: 60))
        XCTAssert(rightHairline.autoresizingMask == [])
        XCTAssert(!rightHairline.isHorizontal)
        
        // Bottom, 1x, no inset, with mask.
        Samples.window.screen = TestScreen.at3x
        let bottomHairline = Hairline.new(in: Samples.window, at: .maxYEdge, autoresize: true)
        XCTAssert(bottomHairline.frame == CGRect(x: 0, y: 50 - UIScreen.hairlineWidth(for: 3), width: 100, height: UIScreen.hairlineWidth(for: 3)))
        XCTAssert(bottomHairline.autoresizingMask == [ .flexibleWidth, .flexibleTopMargin ])
        XCTAssert(bottomHairline.isHorizontal)
    }
    
    func testProperties() {
        // Defaults to horizontal, irrespective of frame.
        let hairline = Hairline()
        XCTAssert(hairline.isHorizontal)
        XCTAssert(hairline.length == 0)
        
        // Frame alone does not imply orientation.
        hairline.frame.size = CGSize(width: 0.5, height: 100)
        XCTAssert(hairline.isHorizontal)
        XCTAssert(hairline.length == 0.5)
        
        // Orientation can be changed without also changing frame, but can entail a change to length.
        hairline.isHorizontal = false
        XCTAssert(!hairline.isHorizontal)
        XCTAssert(hairline.length == 100)
    }
    
    func testSizeThatFits() {
        for screen in TestScreen.all {
            Samples.window.screen = screen
            
            Samples.hairline.isHorizontal = true
            XCTAssert(Samples.hairline.sizeThatFits(CGSize(width: 100, height: 100)) == CGSize(width: 100, height: screen.hairlineWidth))
            
            Samples.hairline.isHorizontal = false
            XCTAssert(Samples.hairline.sizeThatFits(CGSize(width: 100, height: 100)) == CGSize(width: screen.hairlineWidth, height: 100))
        }
    }
    
    func testSpanSuperview() {
        // Left, 3x, inset, no mask.
        Samples.window.screen = TestScreen.at3x
        Samples.hairline.spanSuperview(at: .minXEdge, inset: 10, updateAutoresizingMask: false)
        XCTAssert(Samples.hairline.frame == CGRect(x: 0, y: 10, width: CGFloat(1) / 3, height: 30))
        XCTAssert(Samples.hairline.autoresizingMask == [])
        XCTAssert(!Samples.hairline.isHorizontal)
        
        // Top, 2x, no inset, no resizing mask.
        Samples.window.screen = TestScreen.at2x
        Samples.hairline.spanSuperview(at: .minYEdge)
        XCTAssert(Samples.hairline.frame == CGRect(x: 0, y: 0, width: 100, height: 0.5))
        XCTAssert(Samples.hairline.autoresizingMask == [])
        XCTAssert(Samples.hairline.isHorizontal)
        
        // Right, 2x, inset, with mask.
        Samples.window.screen = TestScreen.at2x
        Samples.hairline.spanSuperview(at: .maxXEdge, inset: -5, updateAutoresizingMask: true)
        XCTAssert(Samples.hairline.frame == CGRect(x: 99.5, y: -5, width: 0.5, height: 60))
        XCTAssert(Samples.hairline.autoresizingMask == [ .flexibleHeight, .flexibleLeftMargin ])
        XCTAssert(!Samples.hairline.isHorizontal)
        
        // Bottom, 1x, no inset, with mask.
        Samples.window.screen = TestScreen.at3x
        Samples.hairline.spanSuperview(at: .maxYEdge, updateAutoresizingMask: true)
        XCTAssert(Samples.hairline.frame == CGRect(x: 0, y: 50 - UIScreen.hairlineWidth(for: 3), width: 100, height: UIScreen.hairlineWidth(for: 3)))
        XCTAssert(Samples.hairline.autoresizingMask == [ .flexibleWidth, .flexibleTopMargin ])
        XCTAssert(Samples.hairline.isHorizontal)
    }
    
}
