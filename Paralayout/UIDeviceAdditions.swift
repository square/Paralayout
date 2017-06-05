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
    
    /// Whether or not this screen is shorter than a 4" phone's (e.g. an iPhone 4).
    public var isShortPhone: Bool {
        return (isPhone && UIScreen.main.bounds.height < ScreenSize.fourInchPhone.height)
    }
    
    /// Whether or not this screen is narrower than a 4.7" phone's (e.g. an iPhone 4 or 5).
    public var isNarrowPhone: Bool {
        return (isPhone && UIScreen.main.bounds.width < ScreenSize.fourPointSevenInchPhone.width)
    }
    
    /// Whether or not this screen is the same size as a 4" phone's (e.g. an iPhone 5).
    public var isFourInchPhone: Bool {
        return (isPhone && UIScreen.main.bounds.size == ScreenSize.fourInchPhone)
    }
    
    /// Whether or not this screen is as large or larger than a 4.7" phone (e.g. an iPhone 6/7 or 6/7 Plus).
    public var isFourPointSevenInchOrLargerPhone: Bool {
        return (isPhone && UIScreen.main.bounds.width >= ScreenSize.fourPointSevenInchPhone.width)
    }
    
    /// Whether or not this screen is as large or larger than a 5.5" phone (e.g. an iPhone 6/7 Plus or newer/larger device).
    public var isFivePointFiveInchOrLargerPhone: Bool {
        return (isPhone && UIScreen.main.bounds.width >= ScreenSize.fivePointFiveInchPhone.width)
    }
    
}


