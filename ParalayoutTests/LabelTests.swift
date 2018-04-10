//
//  Copyright © 2018 Square, Inc.
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


class LabelTests: XCTestCase {
    
    func testCompactTextRectAlignment() {
        let label = Label()
        label.text = "This is some sample text that wraps to two lines"
        label.lineWrapBehavior = .compact
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 17)
        
        let boundsThatFits = CGRect(origin: .zero, size: label.sizeThatFits(CGSize(width: 300, height: 200)))
        
        label.textAlignment = .left
        XCTAssertEqual(label.compactTextRect(forBounds: boundsThatFits), CGRect(x: 0, y: 0, width: 188, height: boundsThatFits.height))
        
        label.textAlignment = .center
        XCTAssertEqual(label.compactTextRect(forBounds: boundsThatFits), CGRect(x: 56, y: 0, width: 188, height: boundsThatFits.height))
        
        label.textAlignment = .right
        XCTAssertEqual(label.compactTextRect(forBounds: boundsThatFits), CGRect(x: 112, y: 0, width: 188, height: boundsThatFits.height))
        
        label.textAlignment = .natural
        label.semanticContentAttribute = .forceLeftToRight
        XCTAssertEqual(label.compactTextRect(forBounds: boundsThatFits), CGRect(x: 0, y: 0, width: 188, height: boundsThatFits.height))
        
        label.textAlignment = .natural
        label.semanticContentAttribute = .forceRightToLeft
        XCTAssertEqual(label.compactTextRect(forBounds: boundsThatFits), CGRect(x: 112, y: 0, width: 188, height: boundsThatFits.height))
    }
}
