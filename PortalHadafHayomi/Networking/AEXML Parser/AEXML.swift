//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

open class Attribute
{
    var key:String!
    var value:String!
}

/**
    This is base class for holding XML structure.

    You can access its structure by using subscript like this: `element["foo"]["bar"]` would return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `AEXMLElement` object.
*/
open class AEXMLElement: Equatable {
    
    // MARK: Properties
    
    /// Every `AEXMLElement` should have its parent element instead of `AEXMLDocument` which parent is `nil`.
    open fileprivate(set) weak var parent: AEXMLElement?
    
    /// Child XML elements.
    open var children: [AEXMLElement] = [AEXMLElement]()
    
    /// XML Element name.
    public let name: String
    
    /// XML Element value.
    open var value: String?
    
    /// XML Element attributesArray of type [NSObject : AnyObject].
    fileprivate(set) var attributesArray: [AnyHashable: Any]
    
    lazy var attributes:[Attribute] = {
        
        var attributes:[Attribute] = []
        
        for (key, value) in self.attributesArray
        {
            let attribute = Attribute()
            attribute.key = key as? String
            attribute.value = value as? String
            
          attributes.append(attribute)
        }
        
        return attributes
        
    }()
    
    func getAttributeByKey(_ key:String) -> Attribute?
    {
        for attribute in self.attributes
        {
            if attribute.key == key
            {
                return attribute
            }
        }
        return nil
    }
    
    /// String representation of `value` property (if `value` is `nil` this is empty String).
    open var stringValue: String { return value ?? String() }
    
    /// Boolean representation of `value` property (if `value` is "true" or 1 this is `True`, otherwise `False`).
    open var boolValue: Bool { return stringValue.lowercased() == "true" || Int(stringValue) == 1 ? true : false }
    
    /// Integer representation of `value` property (this is **0** if `value` can't be represented as Integer).
    open var intValue: Int { return Int(stringValue) ?? 0 }
    
    /// Double representation of `value` property (this is **0.00** if `value` can't be represented as Double).
    open var doubleValue: Double { return Double(stringValue)! }
    
    // MARK: Lifecycle
    
    /**
        Designated initializer - `name` is required, others are optional.
    
        - parameter name: XML element name.
        - parameter value: XML element value
        - parameter attributes: XML element attributes
    
        - returns: An initialized `AEXMLElement` object.
    */
    public init(_ name: String, value: String? = nil, attributes: [AnyHashable: Any] = [AnyHashable: Any]()) {
        self.name = name
        self.value = value
        self.attributesArray = attributes
    }
    
    // MARK: XML Read
    
    /// This element name is used when unable to find element.
    open class var errorElementName: String { return "AEXMLError" }
    
    // The first element with given name **(AEXMLError element if not exists)**.
    open subscript(key: String) -> AEXMLElement {
        if name == AEXMLElement.errorElementName {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            return filtered.count > 0 ? filtered.first! : AEXMLElement(AEXMLElement.errorElementName, value: "element <\(key)> not found")
        }
    }
    
    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    open var all: [AEXMLElement]? { return parent?.children.filter { $0.name == self.name } }
    
    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    open var first: AEXMLElement? { return all?.first }
    
    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    open var last: AEXMLElement? { return all?.last }
    
    /// Returns number of all elements with equal name as `self`.
    open var count: Int { return all?.count ?? 0 }
    
    /**
        Returns all element with given attributes.
    
        - parameter attributes: Array of Keys (`NSObject`) and Value (`AnyObject`) - both must conform to `Equatable` protocol.
    
        - returns: Optional Array of found XML elements.
    */
    open func allWithAttributes <K: NSObject, V: AnyObject> (_ attributes: [K : V]) -> [AEXMLElement]? where K: Equatable, V: Equatable {
        var found = [AEXMLElement]()
        if let elements = all {
            for element in elements {
                var countAttributes = 0
                for (key, value) in attributes {
                    if element.attributesArray[key] as? V == value {
                        countAttributes += 1
                    }
                }
                if countAttributes == attributes.count {
                    found.append(element)
                }
            }
            return found.count > 0 ? found : nil
        } else {
            return nil
        }
    }
    
    /**
        Counts elements with given attributes.
    
        - parameter attributes: Array of Keys (`NSObject`) and Value (`AnyObject`) - both must conform to `Equatable` protocol.
    
        - returns: Number of elements.
    */
    open func countWithAttributes <K: NSObject, V: AnyObject> (_ attributes: [K : V]) -> Int where K: Equatable, V: Equatable {
        return allWithAttributes(attributes)?.count ?? 0
    }
    
    // MARK: XML Write
    
    /**
        Adds child XML element to `self`.
    
        - parameter child: Child XML element to add.
    
        - returns: Child XML element with `self` as `parent`.
    */
    open func addChild(_ child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    /**
        Adds child XML element to `self`.
        
        - parameter name: Child XML element name.
        - parameter value: Child XML element value.
        - parameter attributes: Child XML element attributes.
        
        - returns: Child XML element with `self` as `parent`.
    */
    open func addChild(name: String, value: String? = nil, attributes: [AnyHashable: Any] = [AnyHashable: Any]()) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    /**
        Adds given attribute to `self`.
    
        - parameter name: Attribute name.
        - parameter value: Attribute value.
    */
    open func addAttribute(_ name: NSObject, value: AnyObject) {
        attributesArray[name] = value
    }
    
    /**
        Adds given attributes to `self`.
        
        - parameter attributes: Dictionary of Attribute names and values.
    */
    open func addAttributes(_ attributes: [AnyHashable: Any]) {
        for (attributeName, attributeValue) in attributes {
            addAttribute(attributeName as NSObject, value: attributeValue as AnyObject)
        }
    }
    
    /// Removes `self` from `parent` XML element.
    open func removeFromParent() {
        parent?.removeChild(self)
    }
    
    fileprivate func removeChild(_ child: AEXMLElement) {
        if let childIndex = children.index(of: child) {
            children.remove(at: childIndex)
        }
    }
    
    fileprivate var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count += 1
            element = parent
        }
        return count
    }
    
    fileprivate func indentation(_ count: Int) -> String {
        var indent = String()
        if count > 0 {
            for _ in 0..<count {
                indent += "\t"
            }
        }
        return indent
    }
    
    /// Complete hierarchy of `self` and `children` in **XML** formatted String
    open var xmlString: String {
        var xml = String()
        
        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"
        
        if attributesArray.count > 0 {
            // insert attributes
            for (key, value) in attributesArray {
                xml += " \(key)=\"\(value)\""
            }
        }
        
        if value == nil && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(stringValue)</\(name)>"
            }
        }
        
        return xml
    }
    
    /// Same as `xmlString` but without `\n` and `\t` characters
    open var xmlStringCompact: String {
        let chars = CharacterSet(charactersIn: "\n\t")
        return xmlString.components(separatedBy: chars).joined(separator: "")
    }
}

// MARK: -

/**
    This class is inherited from `AEXMLElement` and has a few addons to represent **XML Document**.

    XML Parsing is also done with this object.
*/
public class AEXMLDocument: AEXMLElement {
    
    // MARK: Properties
    
    /// This is only used for XML Document header (default value is 1.0).
    let version: Double
    
    /// This is only used for XML Document header (default value is "utf-8").
    let encoding: String
    
    /// This is only used for XML Document header (default value is "no").
    let standalone: String
    
    /// Root (the first child element) element of XML Document **(AEXMLError element if not exists)**.
    var root: AEXMLElement { return children.count == 1 ? children.first! : AEXMLElement(AEXMLElement.errorElementName, value: "XML Document must have root element.") }
    
    // MARK: Lifecycle
    
    /**
        Designated initializer - Creates and returns XML Document object.
    
        - parameter version: Version value for XML Document header (defaults to 1.0).
        - parameter encoding: Encoding value for XML Document header (defaults to "utf-8").
        - parameter standalone: Standalone value for XML Document header (defaults to "no").
        - parameter root: Root XML element for XML Document (defaults to `nil`).
    
        - returns: An initialized XML Document object.
    */
    public init(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", root: AEXMLElement? = nil) {
        // set document properties
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
        
        // init super with default name
        super.init("AEXMLDocument")
        
        // document has no parent element
        parent = nil
        
        // add root element to document (if any)
        if let rootElement = root {
            addChild(rootElement)
        }
    }
    
    /**
        Convenience initializer - used for parsing XML data (by calling `readXMLData:` internally).
    
        - parameter version: Version value for XML Document header (defaults to 1.0).
        - parameter encoding: Encoding value for XML Document header (defaults to "utf-8").
        - parameter standalone: Standalone value for XML Document header (defaults to "no").
        - parameter xmlData: XML data to parse.
        - parameter error: If there is an error reading in the data, upon return contains an `NSError` object that describes the problem.
    
        - returns: An initialized XML Document object containing the parsed data. Returns `nil` if the data could not be parsed.
    */
    public convenience init(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", xmlData: Data) throws {
        self.init(version: version, encoding: encoding, standalone: standalone)
        if let parseError = readXMLData(xmlData) {
            throw parseError
        }
    }
    
    // MARK: Read XML
    
    /**
        Creates instance of `AEXMLParser` (private class which is simple wrapper around `NSXMLParser`) and starts parsing the given XML data.
    
        - parameter data: XML which should be parsed.
    
        - returns: `NSError` if parsing is not successfull, otherwise `nil`.
    */
    open func readXMLData(_ data: Data) -> NSError? {
        children.removeAll(keepingCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        return xmlParser.tryParsing() ?? nil
    }
    
    // MARK: Override
    
    /// Override of `xmlString` property of `AEXMLElement` - it just inserts XML Document header at the beginning.
    open override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}

// MARK: -

class AEXMLParser: NSObject, XMLParserDelegate {
    
    // MARK: Properties
    
    let xmlDocument: AEXMLDocument
    let xmlData: Data
    
    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    var parseError: NSError?
    
    // MARK: Lifecycle
    
    init(xmlDocument: AEXMLDocument, xmlData: Data) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }
    
    // MARK: XML Parse
    
    func tryParsing() -> NSError? {
        var success = false
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        success = parser.parse()
        return success ? nil : parseError
    }
    
    // MARK: NSXMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
        let newValue = currentValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        currentElement?.value = newValue == String() ? nil : newValue
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError as NSError?
    }
    
}

// MARK: - Equatable

/**
    Implementation of `Equatable` protocol for `AEXMLElement`.
*/
public func ==(lhs: AEXMLElement, rhs: AEXMLElement) -> Bool {
    if lhs.name != rhs.name { return false }
    if lhs.value != rhs.value { return false }
    if lhs.parent != rhs.parent { return false }
    if lhs.children != rhs.children { return false }
    if lhs.attributesArray != rhs.attributesArray { return false }
    return true
}

/**
    Implementation of `Equatable` protocol for `AEXMLElement`.
*/
public func !=(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any]) -> Bool {
    
    for (key, lhsValue) in lhs {
        if let rhsValue: AnyObject = rhs[key] as AnyObject? {
            if !((lhsValue as AnyObject) === rhsValue) { return true }
        } else { return true }
    }

    return false
}
