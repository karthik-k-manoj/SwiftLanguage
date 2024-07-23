//
//  JSONEncodingUseCase.swift
//  FoundationTypeTests
//
//  Created by Karthik K Manoj on 23/07/24.
//

import XCTest

final class JSONEncodingUseCase: XCTestCase {
    func test_simpleJSONEncoding_isNotEqual_onDifferentOutputFormatting() {
        struct Product: Encodable {
            let id: Int
            let name: String
            let available: Bool
        }
        
        let product = Product(id: 1, name: "LG", available: false)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let dataWithOutputFormatting = try jsonEncoder.encode(product)
            let jsonStrWithOutputFormatting = String(data: dataWithOutputFormatting, encoding: .utf8)!
            do {
                jsonEncoder.outputFormatting = []
                let dataWithoutOutputFormatting = try jsonEncoder.encode(product)
                let jsonStrWithoutOutputFormatting = String(data: dataWithoutOutputFormatting, encoding: .utf8)!
                
                XCTAssertNotEqual(jsonStrWithOutputFormatting, jsonStrWithoutOutputFormatting)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
