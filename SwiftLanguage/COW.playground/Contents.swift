import Foundation

var greeting = "Hello, playground"

let data = Data(repeating: 1, count: 2)
let nsMutableData = NSMutableData(data: data)
nsMutableData.append(Data(repeating: 2, count: 5))

var nsmutableData2 = nsMutableData

nsmutableData2

// since we are working witht a reference type assigning to a variable does not
// create a copy. So both of variables points to the same memory location

// If we want to make a copy of this then you would need to call

let nsmutableData3 = nsmutableData2.mutableCopy() as! NSMutableData
nsmutableData3.append(Data(repeating: 3, count: 5))
nsmutableData3

// `nsmutableData2` and `nsmutableData3` are two different memory location


// Behavior of Value Types

func address(_ object: UnsafeRawPointer) -> String {
    let address = Int(bitPattern: object)
    return NSString(format: "%p", address) as String
}

do {
    // the value gets copie on assignment, initialisation, argument passing
    var data = Data(repeating: 1, count: 1)
    var copy = data
    /*
     When we create a copy of a struct like Data, the struct gets copied field by field. However, that doesn't mean that all the bytes of this Data value get copied immediately, because Data has an internal reference to the memory, which stores the actual data. So when the struct gets copied, only the reference is copied to the new value. The actual data is copied once we make changes, e.g. by calling append.
     */
    address(&data)
    address(&copy)
    
    struct A { }
    
    var a = A()
    var a1 = a
    
    
    address(&a)
    address(&a1)
}

// Implementing Copy-On-Write
do {
    final class Box<A> {
        var unbox: A
        
        init(_ unbox: A) {
            self.unbox = unbox
        }
    }
    
    struct MyData: CustomDebugStringConvertible {
        var debugDescription: String {
            String(describing: underlyingData)
        }
        var underlyingData = Box(NSMutableData())
        
        var dataForWriting: NSMutableData {
            mutating get {
                if isKnownUniquelyReferenced(&underlyingData) {
                    return underlyingData.unbox
                }
                
                print("making a copy")
                underlyingData = Box(underlyingData.unbox.mutableCopy() as! NSMutableData)
                return underlyingData.unbox
            }
        }
        
        mutating func append(_ data: Data) {
            dataForWriting.append(data)
        }
    }
    
    var data = MyData()
    var copy = data
    
    // Here we can see both are different address but underlying storage is the a reference type
//    address(&data.underlyingData.unbox)
//    address(&copy.underlyingData.unbox)
    
   // data.append(Data(repeating: 2, count: 2))
    
    // Have the same data
    data
    copy
    
    // So we created a struct but that doesn't exhibit value semantic.
    // When data gets assigned to copy, it gets copied field by field and the only
    // field it contains is a reference to an `NSMutableData` instance. So now values
    // of both variables now contain a reference to the same `NSMutableData` instance
    
    var copy2 = data
    data.append(Data(repeating: 10, count: 1))
    
    // Only data has changed, copy2 is not changed. On append we made sure we created
    // a copy of the underlying data
    data.underlyingData.unbox
    copy2.underlyingData.unbox
    
    // we are making copy on each time append is called. So if a value type is the only
    // owner of the reference type then we do not need to make extra copy after each append method
    
    data.append(Data(repeating: 20, count: 1))
    
    data.underlyingData.unbox
    copy2.underlyingData.unbox
 }

do {
    // Copy on write is a optimization technique created specifically for value types
    // it is required to improve performance
    // Only specific built in types such as collection array, dict, set have COW implemented
    // User defiend structs do not have COW implemented. If we have a value type that has lot of data set then we can improve the performance by implementing COW
    
    class Ref<T> {
        var value: T
        
        init(_ value: T) {
            self.value = value
        }
    }
    
    struct Box<T> {
        var ref: Ref<T>
        
        init(ref: Ref<T>) {
            self.ref = ref
        }
        
        var value: T {
            get {
                ref.value
            }
            
            set {
                if !isKnownUniquelyReferenced(&ref) {
                    ref = Ref(newValue)
                    return
                }
                
                ref.value = newValue
            }
        }
    }
}
