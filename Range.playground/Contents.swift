import UIKit

var greeting = "Hello, playground"

/*
 Range is an interval of values and is defined by it's lower and upper bound
 
 You can create range with either
    1) ..< called half-open range operator that doesn't include the upper bound
    2) ... called closed range operator that includes lower and upper bound
 */

// 0 to 9, 10 is not included
let singleDigitNumber = 0..<10 // 0: lower bound, 10: upper bound
Array(singleDigitNumber)

let lowercaseLetters = Character("a")...Character("z")

/*
 There are also prefix and postfix variants of these operators, which are used to expressed one-sided range
 */

let fromZero = 0... // Prefix
let upToZ = ..<Character("z") // Postfix

/*
 Both above range operator i.e half-open ranger operator and closed range operator
 have generic bound parameter. The only requirement is Bound must be Comparable.
 For e.g. the lowerCaseLetter above is of type ClosedRange<Character>
 */

// Most basic operation on a range is to test whether or not it contains certain elements

singleDigitNumber.contains(9)
lowercaseLetters.overlaps("c"..<"f")

do {
    let fromAToD = Character("a")...Character("d")
    fromAToD.overlaps(Character("d")...Character("f"))
    
    let fromAUptoD = Character("a")..<Character("d") // here d is not included
    fromAUptoD.overlaps(Character("d")...Character("f")) // since d is not included in range the method is called on, it returns false
}

/*
 There are separate types for half-open and closed range because both have a place
 
 1) Only a half-open range can represent an empty interval (when lower & upper bound
    are equal as in 5..<5)
 
 2) Only a closed range can contain a maximum value it's elements type can represent.
    (e.g. 0...Int.max). A half open range always requires at least one representable value
    that's greater than the highest value in the range.
 */

let closedRangeNonEmpty = (5...5).isEmpty // false
let halfOpenRangeEmpty = (5..<5).isEmpty // true

/*
 Not all range can be iterated using for-in loop. Why?
 Range only conforms to the collection protocol conditionally
 if it element type conforms to `Strideable` (i.e you can jump from one element to
 another by adding an offset) and if stide steps themselves are integers
 */

/*
extension Range: Sequence where Bound: Strideable. Bound.Stride: SignedInteger { ... }
 
In other words a range must be countable for it to be iterated over. Valid bounds for
countable ranges (i.e match the constraints) include integer and pointer types but not
not floating-point type becase of the integer constraint on the types Stride
 
If you need to iterate over consecutive floating point values you can use stridge(from: to: by) and stride(from:through:by)
 
 Before conditional protocol conformance was introduced in Swift 4.1 and 4.2 we had
 `CountableRnage` and `CountableClosedRange` for distinguish countable from non-countable range. The name still exits as typealiases for backward compatibility.
 
 You can use them as shorthand instead of the mouthful range-plus constraints. So it is till there for backward compatibility and only you can use it constraint
*/

/*
public typealias CountableRange<Bound: Strideable> = Range<Bound> where Bound.Stride: SignedInteger
 */

/*
 Partial ranges are constructed using ... (closed) or ...< (half open) as a prefix or postfix operator. Why partial? Because they're missing one of their bounds/
 */

let fromA: PartialRangeFrom<Character> = Character("a")...
let throughZ: PartialRangeThrough<Int> = ...2
let upto10: PartialRangeUpTo<Int> = ..<10

/*
 Only `PartialRangeFrom` wil be Sequence if the Bounds.Stride is SignedInterger
 `PartialRangeThrough` and `PartialRangeUpto` do not conform to `Sequence` protocol at all
 because they are missing a lower bound`
 
 Similar to `CountableRange` there is `CountablePartialRange` for `PartialRangeFrom` but with tigter constraints
 */

// Range Expression
/*
 All five range (Range (half open range), closed range, partialrangeFrom, partialrangeThrough, PartialRangeUpto)
 types conform to RangeExpression protocol.
 Small protocol
    - contains
    - relative “For partial ranges with a missing lower bound, the relative(to:) method adds the collection’s startIndex as the lower bound. For partial ranges with a missing upper bound, the method will use the collection’s endIndex. Partial ranges enable a very compact syntax for slicing collections:”
 
 */

do {
    let numbers = [1, 2, 3, 4]
    numbers[2...] // [3, 4]
    numbers[..<1] // [1]
    numbers[1...2] // [2, 3]
    numbers[...]
}

/*
 This works because corresponding subscript declaration in the Collection protocol takes a RangeExpression rather than one of the five concrete range types. You can even omit both
 bounds to get a slice of the entire collection:
 
 number[...]
 */



