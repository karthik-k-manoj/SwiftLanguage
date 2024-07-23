//
//  JSONDecodingUseCase.swift
//  FoundationTypeTests
//
//  Created by Karthik K Manoj on 23/07/24.
//

import XCTest
import Foundation

final class JSONDecodingUseCase: XCTestCase {
    
    func testSimpleJSONString() throws {
        // valid json string
        let jsonStr = """
        {
            "name": "Karthik",
            "age": "12"
        }
        """
        
        // It is converted from string to json data using .`utf8` encoding
        let jsonData = jsonStr.data(using: .utf8)!
        
        // creates a `JSONDecoder` instance
        let jsonDecoder = JSONDecoder()
        
        // since `[String: String]` type is decodable by default we can use it directly without a custom type
        let dict = try jsonDecoder.decode([String: String].self, from: jsonData)
        
        // assert 
        XCTAssertEqual(dict, ["name": "Karthik", "age": "12"])
    }
}
