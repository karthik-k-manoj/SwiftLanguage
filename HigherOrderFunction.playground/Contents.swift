import UIKit
import SwiftUI
 
// What is a higer order function?
// They are functions which takes one or more functions as arguments or returns a functions.

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


// Filter higher order function

extension Array {
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        
        for x in self where isIncluded(x) {
            result.append(x)
        }
        
        return result
    }
}


let evenSquaredUnder100 = (1..<10).map { $0 * $0 }.filter { $0 % 2 == 0 }

/* Two quick perforamce tips
 
 -  Note that chaining map and filter in this way creates an intermediate array (result of map operation) that's
    then thrown away. This isn't a problem for our small example, but for large collections or long chains, the
    extra allocations can negatively impact performance. We avoid these intermediate arrays by inserting `.lazy`
    at the start of the chain, thereby making all transformations lazy. Only at the end do we convert the lazy
    collection back into a regular array
 */

let lazyFilter = (1..<10).lazy.map { $0 * $0 }.filter { $0 % 2 == 0 }
let filtered = Array(lazyFilter)

/*
    Secondly if you ever find yourself writing something like the following stop!
*/

let bigArray = [1,2,3,4,5]
bigArray.filter { $0 % 2 == 0 }.count > 0

/*
    `filter` creates a brand-new array and proccess every element in the array. But this is unnecessary.
    This code only needs to check if one element matches in which case, `contains(where:) will do the job
*/

bigArray.contains { $0 % 2 == 0 }

/*
    This is much faster for two reasons: it doesn't create a whole new array of the filtered elements just to
    count them, and it exits early - as soon as it finds the first match. Generally, only ever use filter if
    you want all the results.
 */

/*
    Reduce medthod abstracts two parts: the initial value and the function for combing the intermediate value
    (total) and the element (num)
*/

extension Array {
    func reduce<Result>(_ initialValue: Result, _ partialResult: (Result, Element) -> Result) -> Result {
        var total = initialValue
        
        for x in self {
            total = partialResult(total, x)
        }
        
        return total
    }
}


let sum = [0,1,1,2,3,5].reduce(0) { total, num in
    total + num
}

// Operators are functions too, so we could've written the same example like this

let simplifiedSum = [0,1,1,2,3,5].reduce(0, +)

/*
 Output type of reduce doesn't have to the same as the element type. For example, if we want to
 convert a lit of integers into a string with each number followed by a comma and a space, we can do
 the following
*/

let toString = [0,1,1,2,3,5].reduce("") { str, num in
    str + "\(num), "
}

/*
 Another performance tip: reduce is very felxible, and it's common to see it used to build arrays
 and perform other operations. For example, you can implement map and filter using reduce only
*/

extension Array {
    func map2<T>(_ transform: (Element) -> T) -> [T] {
        reduce([]) {
            $0 + [transform($1)]
        }
    }
}

let mapWithReduce = [1,2,3,4].map2 { $0 * $0 }
    

extension Array {
    func filter2(_ isIncluded: (Element) -> Bool) -> [Element] {
        reduce([]) {
            isIncluded($1) ? $0 + [$1] : $0
        }
    }
}

let filterWithReduce = [1,2,3,4].filter2 { $0 % 2 == 0 }

/*
 This is kind of beautiful and has the benefit of not needing those icky imperative for loops. But there is a
 problem. On every executon of the combine function a brand new array is created by appending the transformed
 or included element to the previous. This means both these implementations are O(n^2) and not O(n).
*/


/*
 We can improve this using `inout` parameter for the `Result` type in closure parameter
*/

extension Array {
    func reduce2<Result>(
        _ initialResult: Result,
        _ updateAccumulatingResult: (_ partialResult: inout Result, Element) -> Result
    ) -> Result {
        var total = initialResult
        
        for x in self {
            total = updateAccumulatingResult(&total, x)
        }
        
        return total
    }
}

/* We can now use `reduce2` to update the implement filter method in an optimized way. When using
 `inout` the compiler doesn't have to create a new array each time, so this version of filter is agin
 O(n). When the call to `reduce(into:_:) is inlined by the compiler, the generate code is often
 same as when using a for lopp
*/


extension Array {
    func filter3(_ isIncluded: (Element) -> Bool) -> [Element] {
        reduce(into: []) { partialResult, element in
            if isIncluded(element) {
                partialResult.append(element)
            }
        }
    }
}


let filter3WithReduce2 = [1,2,3,4].filter3 { $0 % 2 == 0 }

/*
 Flatmap: Sometimes you want to map an array where the transformation functions returns another
 array and not a single element. Basically what you do here is go through the array and get back an array
 for each element of the source array, then we call `joined()` to flatten the result into a single array.
 `flatMap` method combines these two operations mapping and flattening into a single step.
*/

/*
 Signature of `flatMap` is almost identical to the `map`, expect it's transformation function returns an array
 The implementation uses `append(contentsOf)` instead of `append(_:) to flatten the result array
*/
extension Array {
    func flatMap<T>(_ transform: (Element) -> [T]) -> [T] {
        var result: [T] = []
        
        for x in self {
            result.append(contentsOf: transform(x))
        }
        
        return result
    }
}

let flattedArray = [1,2,3,4].flatMap {
    ["\($0)"]
}

print("Flatmap: \(flattedArray)")

/*
 Another great use case for `flatMap` is combining elements from different arrays. To get all possible pairs of element in
 two arrays, `flatMap` over one array and then map over the other in the transformation function of `flatMap`
 */

let array1 = ["A", "B", "C", "D"]
let array2 = [1,2,3,4]

let pairsArray = array1.flatMap { x in
    array2.map { y in
        (x,y)
    }
}

print("Pairs Array", pairsArray)

// Iteration using forEach

/*
 Works almost like a for loop. The passed in function is executed once for each element in the sequence.
 It doesn't return anything. It's specifically meant for performing side effects.
 */

// Example

[1,2,3].forEach { element in
    print(element)
}

/*
  We can pass a function name to `forEach` instead of passing a closure expression.
 This can lead to clearer and more concise code
 */

let mainView = UIView()
let childViews = [UIView(), UIView()]

childViews.forEach(mainView.addSubview)

// is more clearer than

for view in childViews {
    mainView.addSubview(view)
}

/* You might think what is the difference between the above and a for loop. `break` and `continue` cannot be used in
 for each as it's a closure that is passed in. `where` clause can only be used in for loop. We should be using for loop
 when there is kind of control flow while looping.
 */

