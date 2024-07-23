//
//  JSONEncodingUseCase.swift
//  FoundationTypeTests
//
//  Created by Karthik K Manoj on 23/07/24.
//

import XCTest

final class JSONEncodingUseCase: XCTestCase {
    func test_simpleJSONEncoding() {
        struct Product: Encodable {
            let id: Int
            let name: String
            let available: Bool
        }
        
        let product = Product(id: 1, name: "LG", available: false)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        do {
            let data = try jsonEncoder.encode(product)
            let jsonStr = String(data: data, encoding: .utf8)!
            print(jsonStr)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
