import UIKit

//// Singleton Design Pattern
//// What is a singleton design pattern?
//// It is one of the design patterns from Gang of Four design pattern books.
//// It ensures that a class can have only one instance throughout applications life cycle.
//// This also ensures that a client cannot create an instance of this type from outside. This means we need to have
//// a private `init`
//// Provides a single point of access? It means we need to have a way to access this object and this should be immutable as per the defintion of singleton i.e. single instance.
//// `static let` is lazy initialization
//// There are two types of Singleton i.e. `Upper case Singleton` we can never create an instance from outside. It's rigid.
//// Lower case singleton` the constraint is upto to the developer to initialize it only once but it does not prevent them from creating more than one instance. One of benefit of lower case singleton is allows testability. We can create mock subtypes and inject it during testing.
//
//// Honestly spearking singleton is being misued by developers in the system. It's often called an anti-pattern because the convenince it gives us to access the object from anywhere in the application. This often leads to tight coupling of singleton object in our application. We can use singleton design pattern if we are sure that the system needs one and only instance throughtout the application and it should never be acccess directly. Instead inject it from the composition root. So codebase is not coupled with it. So here `Logger` is a good candidate to become a singleton as system only needs one logger object to log to console.
//
//// Singleton is only applicable to class as struts are values type. We can never enfornce single copy of a struct.
//
//// Upper case Singleton
//final class Logger1 {
//    static let shared = Logger1()
//
//    private init() {}
//}
//
//// Example of upper case singleton is from Foundation framework is
//
//let shared = URLSession.shared
//
//// Lower case singletone
//
//class Logger2 {
//    static let shared = Logger2()
//}
//
//// Another example of lower case singleton from Foundation framework is
//
//let session = URLSession(configuration: .default)
//
//
//// Another thing to point out is often developer when they see `static` keyword such as `static var shared` consider it to be singleton which is not. This is a global mutabled shared state which is very dangerous as the system can be in an undefined state as the state can be changed from anywhere in the application.

import Foundation
 
func main() {
    let rideManager = RideManager()
 
    let driver2 = Driver(name: "Bob")
    rideManager.addDriver(driver: Driver(name: "Alice"))
    rideManager.addDriver(driver: driver2)
    rideManager.addDriver(driver: Driver(name: "Charlie"))

    // Adding ride requests and printing assigned drivers
    rideManager.addRideRequest(rideDescription: "Ride 1")
    rideManager.addRideRequest(rideDescription: "Ride 2")
    
    driver2.finishRide()
    
    rideManager.addRideRequest(rideDescription: "Ride 3")
    rideManager.addRideRequest(rideDescription: "Ride 4")
}
 
// Driver class
class Driver {
    let name: String
    private(set) var rideCount: Int = 0
 
    init(name: String) {
        self.name = name
    }
 
    func incrementRideCount() {
        rideCount += 1
    }
    
    func finishRide() {
        rideCount -= 1
    }
}
 
// RideManager class
class RideManager {
    private var drivers: [Driver] = []
 
    func addDriver(driver: Driver) {
        drivers.append(driver)
    }
 
    func addRideRequest(rideDescription: String) {
        guard let assignedDriver = findDriverWithLeastRides() else {
            print("No available drivers for ride: \(rideDescription)")
            return
        }
        assignedDriver.incrementRideCount()
        print("Ride: \(rideDescription) assigned to Driver: \(assignedDriver.name)")
    }
    
 
    private func findDriverWithLeastRides() -> Driver? {
        return drivers.min { $0.rideCount < $1.rideCount }
    }
}
 
// Run the main function
main()
