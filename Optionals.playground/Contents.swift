import Foundation
import Cocoa

var greeting = "Hello, playground"


var array = ["one", "two", "three"]

// Basic way to pattern match optional
switch array.firstIndex(of: "four") {
case .some(let idx):
    array.remove(at: idx)
case .none:
    break
}

// More elgant way to pattern match optional
switch array.firstIndex(of: "four") {
case let idx?:
    array.remove(at: idx)
case nil:
    break
}

// if let : short step away from switch statement above.
// optional binding with if let
if let idx = array.firstIndex(of: "four") {
    array.remove(at: idx)
}

let urlString = "https://www.objc.io/logo.png"
if let url = URL(string: urlString),
   let data = try? Data(contentsOf: url), // this blocks curren thread. use URLSession.daat
   let image = NSImage(data: data) {
    let view = NSImageView(image: image)
}

// while let
// a loop that terminates when it's condition returns nil
// you can add boolean clause to your optional binding,
//

while let line = readLine(), !line.isEmpty {
    print(line)
}

let array2 = [1,2,3]
var iterator = array2.makeIterator()
while let i = iterator.next() {
    print(i, terminator: "\n")
}

print("\n")

let array3: [Int?] = [1, 2, nil]

for case let i? in array3 {
    print(i, terminator: "\n")
}

print("\n")

for case let .some(i) in array3 {
    print(i, terminator: "\n")
}

let j = 5

// half open or range =
if case 0..<10 = j  {
    print("\(j) within range")
}

let number = "3"
let opt = Int(number)
if var i = opt {
    
}

do {
    var str: String? = "Hello World"
    let upper: String
    if str != nil {
        upper = str!.uppercased()
    } else {
        fatalError("Cannot convert because it is nil")
    }
    
    let upper2 = str?.uppercased() // method which is called with optional chaining will
                                    // return a result that will be also an optional
}

do {
    // as the name implies optional chaining you are not limited to a single method call after the
    // question mark. You can chain calls on optional values
    
    let str: String? = "Hello World"
    let lower = str?.uppercased().lowercased()
    // the above might suprise as a method called with optional chaining returns an optional
    // but we are not using `?` after uppercased(). Why?. This is because optional chaining is
    // a flattening operation
}
