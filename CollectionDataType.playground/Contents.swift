import UIKit

var greeting = "Hello, playground"

var dict = [1: "One", 2: "Two", 3: "Three"]

if let value = dict.removeValue(forKey: 1) {
    print("\(value) removed from dict")
} else {
    print("No value for the key")
}

if let previousValue = dict.updateValue("Five", forKey: 5) {
    print("\(previousValue) was updated with Five")
} else {
    print("New key value pair 5 and Five added")
}

dict[4] = "Four"
print("Dictionary", dict)
