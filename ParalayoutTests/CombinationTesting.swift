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

import Foundation

func forEachCombination<FirstType: Collection, SecondType: Collection>(
    _ firstCollection: FirstType,
    _ secondCollection: SecondType,
    perform block: (FirstType.Element, SecondType.Element) throws -> Void
) rethrows {
    for firstElement in firstCollection {
        for secondElement in secondCollection {
            try block(firstElement, secondElement)
        }
    }
}

func forEachCombination<FirstType: Collection, SecondType: Collection, ThirdType: Collection>(
    _ firstCollection: FirstType,
    _ secondCollection: SecondType,
    _ thirdCollection: ThirdType,
    perform block: (FirstType.Element, SecondType.Element, ThirdType.Element) throws -> Void
) rethrows {
    for firstElement in firstCollection {
        try forEachCombination(secondCollection, thirdCollection) { secondElement, thirdElement in
            try block(firstElement, secondElement, thirdElement)
        }
    }
}

func forEachCombination<FirstType: Collection, SecondType: Collection, ThirdType: Collection, FourthType: Collection>(
    _ firstCollection: FirstType,
    _ secondCollection: SecondType,
    _ thirdCollection: ThirdType,
    _ fourthCollection: FourthType,
    perform block: (FirstType.Element, SecondType.Element, ThirdType.Element, FourthType.Element) throws -> Void
) rethrows {
    for firstElement in firstCollection {
        try forEachCombination(
            secondCollection,
            thirdCollection,
            fourthCollection
        ) { secondElement, thirdElement, fourthElement in
            try block(firstElement, secondElement, thirdElement, fourthElement)
        }
    }
}

func forEachCombination<FirstType: Collection, SecondType: Collection, ThirdType: Collection, FourthType: Collection, FifthType: Collection>(
    _ firstCollection: FirstType,
    _ secondCollection: SecondType,
    _ thirdCollection: ThirdType,
    _ fourthCollection: FourthType,
    _ fifthCollection: FifthType,
    perform block: (FirstType.Element, SecondType.Element, ThirdType.Element, FourthType.Element, FifthType.Element) throws -> Void
) rethrows {
    for firstElement in firstCollection {
        try forEachCombination(
            secondCollection,
            thirdCollection,
            fourthCollection,
            fifthCollection
        ) { secondElement, thirdElement, fourthElement, fifthElement in
            try block(firstElement, secondElement, thirdElement, fourthElement, fifthElement)
        }
    }
}
