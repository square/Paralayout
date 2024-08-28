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

import SnapshotTesting
import XCTest

class SnapshotTestCase: XCTestCase {

    // MARK: - Private Types

    private struct TestDeviceConfig {

        // MARK: - Public Properties

        let systemVersion: String
        let screenSize: CGSize
        let screenScale: CGFloat

        // MARK: - Public Methods

        func matchesCurrentDevice() -> Bool {
            let device = UIDevice.current
            let screen = UIScreen.main

            return device.systemVersion == systemVersion
                && screen.bounds.size == screenSize
                && screen.scale == screenScale
        }

    }

    // MARK: - Private Static Properties

    private static let testedDevices = [

        // iPhone 15 Pro - iOS 17.5
        TestDeviceConfig(systemVersion: "17.5", screenSize: CGSize(width: 393, height: 852), screenScale: 3),

        // iPad (10th Generation) - iPadOS 17.5
        TestDeviceConfig(systemVersion: "17.5", screenSize: CGSize(width: 820, height: 1180), screenScale: 2),

    ]

    // MARK: - XCTestCase

    override class func setUp() {
        super.setUp()

        guard SnapshotTestCase.testedDevices.contains(where: { $0.matchesCurrentDevice() }) else {
            fatalError("Attempting to run tests on a device for which we have not collected test data")
        }

        isRecording = false
    }

    // MARK: - Public Methods

    func nameForSnapshot(with parameters: [String?]) -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let version = UIDevice.current.systemVersion
        let deviceName = "\(Int(size.width))x\(Int(size.height))-\(version)-\(Int(scale))x"

        let parameters = parameters.compactMap { $0 }

        return (parameters + [deviceName]).joined(separator: "_")
    }

}
