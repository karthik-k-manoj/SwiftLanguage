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
