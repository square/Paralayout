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

import UIKit


/// Screen sizes of known devices.
public enum ScreenSize {
    static let threePointFiveInchPhone  = CGSize(width: 320, height: 480)
    static let fourInchPhone            = CGSize(width: 320, height: 568)
    static let fourPointSevenInchPhone  = CGSize(width: 375, height: 667)
    static let fivePointFiveInchPhone   = CGSize(width: 414, height: 736)
    static let fivePointEightInchPhone  = CGSize(width: 375, height: 812)
}


public extension UIDevice {
    
    /// The physical size of the screen, and scale factor, e.g. '4.7" (2x)' or '5.5" (3x)'.
    public var screenSizeDescription: String {
        let screenSize = UIScreen.main.bounds.size
        let boundsDescription: String
        
        switch screenSize {
        case ScreenSize.threePointFiveInchPhone:
            boundsDescription = "3.5\""
        case ScreenSize.fourInchPhone:
            boundsDescription = "4\""
        case ScreenSize.fourPointSevenInchPhone:
            boundsDescription = "4.7\""
        case ScreenSize.fivePointFiveInchPhone:
            boundsDescription = "5.5\""
        case ScreenSize.fivePointEightInchPhone:
            boundsDescription = "5.8\""
        default:
            boundsDescription = String(format: "Unknown (%.0fx%.0f)", screenSize.width, screenSize.height)
        }
        
        return String(format: "%@ (%.0fx)", boundsDescription, UIScreen.main.scale)
    }
    
    /// Whether or not this device is a phone.
    public var isPhone: Bool {
        switch userInterfaceIdiom {
        case .phone:
            return true
        case .pad, .tv, .carPlay, .unspecified:
            return false
        }
    }
    
    /// Whether or not this device is an iPad.
    public var isPad: Bool {
        switch userInterfaceIdiom {
        case .pad:
            return true
        case .phone, .tv, .carPlay, .unspecified:
            return false
        }
    }
    
}


