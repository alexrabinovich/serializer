//
//  main.swift
//  Serializer
//
//  Created by Aleksei Rabinovich on 27.06.2025.
//

import Foundation

for array in testArrays() {
    print("Original array: \(array)\n")
    print("Sorted array: \(array.sorted())\n")
    let uncompressedString = serializeWithoutCompression(array)
    print("Simple serialization: \"\(uncompressedString)\"\n")
    let compressedString = serializeWithCompression(array)
    print("Serialization with compression: \"\(compressedString)\"\n")
    print("Deserialized array: \(deserialize(compressedString))\n")
    print("Compression ratio: \(Float(compressedString.count)/Float(uncompressedString.count))\n")
    print("--------------------------------------------------------------------------------")
}

func serializeWithoutCompression(_ array: [Int]) -> String {
    return array
        .sorted()
        .map { String($0) }
        .joined(separator: ",")
}

func serializeWithCompression(_ array: [Int]) -> String {
    let countedSet = NSCountedSet(array: array)
    let values = countedSet.objectEnumerator().allObjects as? [Int] ?? []
    
    var resultStrings: [String] = []
    
    var previousValue: Int?
    var previousDelta: Int?
    
    for number in values.sorted() {
        let count = countedSet.count(for: number)
        let countSuffix = count > 1 ? "*\(count)" : ""
        
        if let previous = previousValue {
            let delta = number - previous
            if let thePreviousDelta = previousDelta, thePreviousDelta == delta {
                resultStrings.append(countSuffix)
            } else {
                resultStrings.append("\(delta)" + countSuffix)
                previousDelta = nil
            }
            previousDelta = delta
        } else {
            resultStrings.append("\(number)" + countSuffix)
        }
        previousValue = number
    }
    
    return resultStrings.joined(separator: ",")
}

func deserialize(_ string: String) -> [Int] {
    let elements = string.components(separatedBy: ",")
    var result: [Int] = []
    
    var previousNumber: Int?
    var previousDelta: Int?
    
    for element in elements {
        let components = element.components(separatedBy: "*")
        guard let firstComponent = components.first else { continue }
        let count = components.count == 1 ? 1 : Int(components.last!)!
        
        if let thePreviousNumber = previousNumber {
            if firstComponent == "", let thePreviousDelta = previousDelta {
                let number = thePreviousNumber + thePreviousDelta
                for _ in 1...count {
                    result.append(number)
                }
                previousNumber = number
            } else if let delta = Int(firstComponent) {
                let number = thePreviousNumber + delta
                for _ in 1...count {
                    result.append(number)
                }
                previousNumber = number
                previousDelta = delta
            }
        } else if let number = Int(firstComponent) {
            for _ in 1...count {
                result.append(number)
            }
            previousNumber = number
        }
    }
    
    return result
}

func testArrays() -> [[Int]] {
    var arrays: [[Int]] = []
    
    arrays.append([1])
    arrays.append([10])
    arrays.append([1, 1])
    arrays.append([1, 22])
    arrays.append([10, 10])
    arrays.append([105, 11])
    arrays.append([100, 101])
    arrays.append([1, 1, 1])
    arrays.append([1, 2, 35])
    arrays.append([10, 10, 10])
    arrays.append([100, 101, 200])
    
    
    [50, 100, 500, 1000].forEach { count in
        var newArray: [Int] = []
        for _ in 1...count {
            newArray.append(Int.random(in: 1...300))
        }
        arrays.append(newArray)
    }
    
    var newArray: [Int] = []
    
    for number in 1...9 {
        newArray.append(number)
    }
    arrays.append(newArray)
    newArray = []
    
    for number in 10...99 {
        newArray.append(number)
    }
    arrays.append(newArray)
    newArray = []
    
    for number in 100...300 {
        newArray.append(number)
    }
    arrays.append(newArray)
    newArray = []
    
    for number in 1...300 {
        for _ in 0..<3 {
            newArray.append(number)
        }
    }
    arrays.append(newArray)
    newArray = []
    
    return arrays
}
