import UIKit
 
/*
 Transforming all elements of an array requries a lot of code which includes
 creating a new array, looping through the array and appending to it.
 Swift arrays have a map method which was adopted from functional programming.
*/

let nums = [1, 2, 3, 4]
let squared = nums.map { element in element * element }

/* This version has three main advantages
 - it's shorter
 - less room for error prone
 - more importanlty it's clearer and all clutter has been removed
 - once you see map you immediately know a function will be applied to every element
   and return a new array of transformed element
 - declaration of `squared` need to be `var` it can be `let` if appropriate
 - type of the content of the new array can be infered from the function passed to map, `squared`
   needs to be explicitly typed
*/

// Possbile implementation of `map`. In Swift it's an extension on `Sequence` protocol


extension Array {
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        
        for element in self {
            result.append(transform(element))
        }
        
        return result
    }
}

/*
 - `Element` is generic placeholder for whatever type the array contains.
 -`T` is a new placeholder that represent the result of the element transformation.
   It's known from the return type of the transformation closure
*/

/*
 Really the signature of this method should be below indicating `map` will forward any error
 the transformation function might throw to the caller
*/

extension Array {
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] { [] }
}

/* If you find yourself iterating over an array to perform same task or similar one more
 than couple of times in your code, consider writing a short extension to `Array`. For example
 following coe splits an array into groups of adjacement equal elements
 */

let array = [1,2,2,2,3,4,4]
var result: [[Int]] = array.isEmpty ? [] : [[array[0]]]
for (previous, current) in zip(array, array.dropFirst()) {
    if previous == current {
        result[result.endIndex - 1].append(current)
    } else {
        result.append([current])
    }
}

print("Result", result)

/*
    We can improve this with a split high order function that loops over the array in pairts of a
    adjacent elments and logic to split varies from between application
*/

extension Array {
    func split(where condition: (Element, Element) -> Bool) -> [[Element]] {
        var result = self.isEmpty ? [] : [[self[0]]]
        
        for (previous, current) in zip(self, self.dropFirst()) {
            if condition(previous, current) {
                result.append([current])
            } else {
                result[result.endIndex - 1].append(current)
            }
        }
        
        return result
    }
}

let parts = array.split { $0 != $1 }

// or simpify it even more as

let part2 = array.split(where: !=)

/*
    split(where:) operation is also part of Apple's Swift Algorthms package under the name `chunked(by:)`
*/

/*
    Stateful closure with a high order function map to implement `accumulate` high order function
*/

extension Array {
    func accumulate<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> [Result] {
        var running = initialResult
        
        return map { next in
            running = nextPartialResult(running, next)
            return running
        }
    }
}

[1,2,3,4].accumulate(0, +)
