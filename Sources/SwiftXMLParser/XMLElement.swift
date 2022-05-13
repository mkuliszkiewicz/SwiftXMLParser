// Copyright © 2022 Maciej Banasiewicz. All rights reserved.

public final class XMLElement: Hashable {
    public let name: String
    public private(set) var attributes: [String: String] = [:]
    public private(set) var children: [String: [XMLElement]] = [:]
    public private(set) var texts: [String] = []
    public private(set) var comments: [String] = []
    
    init(name: String) {
        self.name = name
    }
    
    func add(_ child: XMLElement) {
        let childName = child.name.lowercased()
        if var existingArray = children[childName] {
            existingArray.append(child)
            children[childName] = existingArray
        } else {
            children[childName] = [child]
        }
    }
    
    func add(_ attributes: [String: String]) {
        let lowercasedKeys = attributes.map { (tuple) -> (key: String, value: String) in
            let (key, value) = tuple
            return (key.lowercased(), value)
        }
        self.attributes.merge(lowercasedKeys, uniquingKeysWith: { (lhs, _) in lhs })
    }
    
    func add(_ text: String) {
        let sanitizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedText.isEmpty else { return }
        texts.append(sanitizedText)
    }
    
    func addComment(_ comment: String) {
        comments.append(comment)
    }
    
    public static func == (lhs: XMLElement, rhs: XMLElement) -> Bool {
        return lhs.name == rhs.name &&
               lhs.attributes == rhs.attributes &&
               lhs.children == rhs.children &&
               lhs.texts == rhs.texts &&
               lhs.comments == rhs.comments
    }
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        attributes.hash(into: &hasher)
        children.hash(into: &hasher)
        texts.hash(into: &hasher)
        comments.hash(into: &hasher)
    }
}

extension XMLElement: CustomStringConvertible {
    public var description: String {
        "XMLElement -> name: \(name) texts: \(String(describing: texts)) children: \(Array(children.keys)) attributes: \(attributes)"
    }
}
