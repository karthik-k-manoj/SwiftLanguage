import UIKit

var greeting = "Hello, playground"

var mainDict = [1: "One", 2: "Two", 3: "Three"]

// Removing a value for the key
if let value = mainDict.removeValue(forKey: 1) {
    print("\(value) removed from dict")
} else {
    print("No value for the key")
}

mainDict[1] = nil

// Updating a value for the key
if let previousValue = mainDict.updateValue("Five", forKey: 5) {
    print("\(previousValue) was updated with Five")
} else {
    print("New key value pair 5 and Five added")
}

mainDict[4] = "Four"
print("Dictionary", mainDict)

// Merging two dictionary and if there is duplicate key, you can decide which dictionary value to be considered
let otherDict = [2: "TWO"]
let mergedDict = mainDict.merging(otherDict) { firstDictValue, secondDictValue in
    // This closure is called only for duplicate key.
    return secondDictValue
}

print(mergedDict)

// Create dictionary from key value pairs, if keys are duplicating perform the closure to make it unique key
extension Sequence where Element: Hashable {
    var frequencies: [Element: Int] {
        let frequencyParis = self.map { ($0, 1)}
        return Dictionary(frequencyParis) { $0 + $1 }
    }
}

do {
    let frequencies = "hello".frequencies
    frequencies.filter { $0.value >  1 }

    let myDictionary = ["karthik": 30, "megha": 32]
    let array = myDictionary.map { key, value in
        return key
    }
}


