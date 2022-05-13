// Copyright © 2022 Maciej Banasiewicz. All rights reserved.

import XCTest
@testable import SwiftXMLParser

final class SwiftXMLParserTests: XCTestCase {
    private func loadData(_ fileName: String) throws -> Data {
        enum LoadError: Swift.Error { case unableToLoad }
        
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "xml") else { 
            throw LoadError.unableToLoad 
        }
        
        return try Data(contentsOf: url)
    }
    
    func testParsingSimpleXml() async throws {
        // Arrange
        let sut = SwiftXMLParser(try loadData("simple"))
        let referenceRootNode = XMLElement(name: "level1")
        let subNode = XMLElement(name: "level2")
        let textNode = XMLElement(name: "text")
        textNode.add("text")
        subNode.add(textNode)
        referenceRootNode.add(subNode)
        
        // Act
        let result = try await sut.parse()
        
        // Assert
        XCTAssertEqual(result, referenceRootNode)
    }
}
