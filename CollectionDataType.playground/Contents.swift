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

do {
    let intValueDict = ["karthik": 30, "megha": 32]
    // Want to convert this dict to [String: String]
    let stringValueDict = intValueDict.mapValues { value in
        "\(value)"
    }
    
    stringValueDict
}

// Dictionaries are hash tables. A dict assigns each key a position in its
// underlying storage array based on the keys hash value. Hence key needs to be
// `Hashable`.


// enum without assoicated types are `Hashable` even without declaring explicitiy. Not only do this save impl work but it also keep the imp
// up to date automatically as properties gets added or removed

/*
 if you can't make a type hashable either because it's a class or you
 don't want one or more stored properties be considered for hashing purpose
 you first need to make the type  `Equatable` and then you can implement
 the `hash(into) requirement of the Hashable protocol.
 
 two instances are = (as defined by == impl) must have the same hash value.
 the reverse isn't true two instances with the same hash value don't necessarily
 compaure equally.
 
 If you need deterministic hashing (e.g. for tests) you can disable random seeding by setting the environment variable SWIFT_DETERMINISTIC_HASHING=1` but you shouldn't do this in production
 
 finally be careful when using type that don't have value semantics (e.g. mutable objects) as dic keys. If you mutate an object asfter using it as dict key in a way taht changes its hash value and or equality you won't be able to find it again in the dictionary. The dictionary now stores the object in the wrong slot effectively corrupting internal storage
 
 */

do {
    // using default value for a dictionary
    let dict = ["name": "karthik", "profession": "iOS Developer"]
    // If the key does not exist then print the default value
    print(dict["name", default: "noValue"])
}
