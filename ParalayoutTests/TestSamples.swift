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


final class TestScreen: UIScreen {
    static let at1x = TestScreen(testScaleFactor: 1)
    static let at2x = TestScreen(testScaleFactor: 2)
    static let at3x = TestScreen(testScaleFactor: 3)
    
    static var all: [UIScreen] {
        return [ UIScreen.main, TestScreen.at1x, TestScreen.at2x, TestScreen.at3x ]
    }
    
    let testScaleFactor: CGFloat
    
    init(testScaleFactor: CGFloat) {
        self.testScaleFactor = testScaleFactor
        super.init()
    }
    
    override var scale: CGFloat {
        return testScaleFactor
    }
}
