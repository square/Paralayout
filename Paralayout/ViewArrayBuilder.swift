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

import UIKit

#if swift(>=5.4)
@resultBuilder
public struct ViewArrayBuilder {

    // Build expressions, which are turned into partial results.

    public static func buildExpression(_ component: UIView) -> [UIView] {
        return [component]
    }
    public static func buildExpression(_ component: [UIView?]) -> [UIView] {
        return component.compactMap { $0 }
    }
    public static func buildExpression(_ component: [UIView]) -> [UIView] {
        return component
    }
    public static func buildExpression(_ component: UIView?) -> [UIView] {
        return [component].compactMap { $0 }
    }

    // Build partial results, which accumulate.

    public static func buildPartialBlock(first: UIView) -> [UIView] {
        return [first]
    }
    public static func buildPartialBlock(first: [UIView]) -> [UIView] {
        return first
    }
    public static func buildPartialBlock(accumulated: UIView, next: UIView) -> [UIView] {
        return [accumulated, next]
    }
    public static func buildPartialBlock(accumulated: UIView, next: [UIView]) -> [UIView] {
        return [accumulated] + next
    }
    public static func buildPartialBlock(accumulated: [UIView], next: UIView) -> [UIView] {
        return accumulated + [next]
    }
    public static func buildPartialBlock(accumulated: [UIView], next: [UIView]) -> [UIView] {
        return accumulated + next
    }

    // Build if statements

    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        return component ?? []
    }
    public static func buildOptional(_ component: [UIView]) -> [UIView] {
        return component
    }

    // Build if-else and switch statements

    public static func buildEither(first component: [UIView]) -> [UIView] {
        return component
    }
    public static func buildEither(second component: [UIView]) -> [UIView] {
        return component
    }

    // Build for-loop statements

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        return components.flatMap { $0 }
    }

    // Build the blocks that turn into results.

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        return components.flatMap { $0 }
    }

}
#endif
