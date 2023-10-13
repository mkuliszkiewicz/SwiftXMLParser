// Copyright © 2022 Maciej Kuliszkiewicz. All rights reserved.

import Foundation

public final class SwiftXMLParser: NSObject {
    private var stack: [XMLElement] = []
    private var result = NSDictionary()
    private var root: XMLElement?
    private var completion: (Result<XMLElement, Error>) -> Void = { _ in }
    private let queue = DispatchQueue(label: "com.mb.xmlParsing")
    private var parser: XMLParser?
    private let data: Data
    
    enum ParserError: Swift.Error {
        case emptyData
    }
    
    public init(_ data: Data) {
        self.data = data
    }

    @available(macOS 10.15, *)
    public func parse() async throws -> XMLElement {
        try await withCheckedThrowingContinuation { continuation in
            self.parse { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let element):
                    continuation.resume(returning: element)
                }
            }
        }
    }

    public func parse(_ completion: @escaping (Result<XMLElement, Error>) -> Void) {
        self.completion = completion
        let data = self.data
        
        guard !data.isEmpty else {
            completion(.failure(ParserError.emptyData))
            return
        }
        
        queue.async {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            self.parser = parser
        }
    }
}

extension SwiftXMLParser: XMLParserDelegate {
    public func parserDidEndDocument(
        _ parser: XMLParser
    ) {
        guard let root = root else { return }
        completion(.success(root))
    }
    
    public func parser(
        _ parser: XMLParser, 
        didStartElement elementName: String, 
        namespaceURI: String?, 
        qualifiedName qName: String?, 
        attributes attributeDict: [String: String] = [:]
    ) {
        
        let newElement = XMLElement(name: elementName)
        newElement.add(attributeDict)
        
        if root == nil {
            root = newElement
            stack.append(newElement)
        } else {
            stack.last?.add(newElement)
            stack.append(newElement)
        }
    }
    
    public func parser(
        _ parser: XMLParser, 
        didEndElement elementName: String, 
        namespaceURI: String?, 
        qualifiedName qName: String?
    ) {
        _ = stack.popLast()
    }
    
    // MARK: - Text
    public func parser(
        _ parser: XMLParser, 
        foundCharacters string: String
    ) {
        stack.last?.add(string)
    }
    
    public func parser(
        _ parser: XMLParser, 
        foundComment comment: String
    ) {
        stack.last?.addComment(comment)
    }
    
    public func parser(
        _ parser: XMLParser, 
        foundCDATA CDATABlock: Data
    ) {
        guard let cdataString = String(data: CDATABlock, encoding: .utf8) else { return }
        stack.last?.add(cdataString)
    }
    
    // MARK: - Errors
    public func parser(
        _ parser: XMLParser, 
        parseErrorOccurred parseError: Error
    ) {
        debugPrint("Failed to parse XML, line: \(parser.lineNumber), column: \(parser.columnNumber) \(parseError)")
        completion(.failure(parseError))
    }
}
