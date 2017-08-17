/*
     MIT License
 
     Copyright (c) 2017 Tribal Worldwide London
 
     Permission is hereby granted, free of charge, to any person obtaining a copy
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:
 
     The above copyright notice and this permission notice shall be included in all
     copies or substantial portions of the Software.
 
     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     SOFTWARE.
 */

import Foundation

enum AttributeType {
    case int16
    case int32
    case int64
    case decimal
    case double
    case float
    case string
    case boolean
    case date
    case binaryData
    case transformable
    case uuid
    case uri
    case timeInterval
    case number
    case undefined
    
    static func fromString(_ str: String) -> AttributeType {
        switch str.lowercased() {
        case "integer 16": return .int16
        case "integer 32": return .int32
        case "integer 64": return .int64
        case "decimal": return .decimal
        case "double": return .double
        case "float": return .float
        case "string": return .string
        case "boolean": return .boolean
        case "date": return .date
        case "binary": return .binaryData
        case "uuid": return .uuid
        case "uri": return .uri
        case "transformable": return .transformable
        default: return .undefined
        }
    }
    
    func toTypeName() -> String {
        switch self {
        case .int16: return "Int16"
        case .int32: return "Int32"
        case .int64: return "Int64"
        case .decimal: return "NSDecimalNumber"
        case .double: return "Double"
        case .float: return "Float"
        case .string: return "String"
        case .boolean: return "Bool"
        case .date: return "NSDate"
        case .binaryData: return "NSData"
        case .transformable: return "NSObject"
        case .uuid: return "UUID"
        case .uri: return "URL"
        case .timeInterval: return "TimeInterval"
        case .number: return "NSNumber"
        case .undefined: return "Any"
        }
    }
    
    func isScalarType() -> Bool {
        switch self {
        case .int16: return true
        case .int32: return true
        case .int64: return true
        case .double: return true
        case .float: return true
        case .boolean: return true
        case .timeInterval: return true
        default: return false
        }
    }
    
    func toScalarType() -> AttributeType {
        switch self {
        case .date: return .timeInterval
        default:
            return self
        }
    }
    
    func toNonScalarType() -> AttributeType {
        switch self {
        case .int16: return .number
        case .int32: return .number
        case .int64: return .number
        case .double: return .number
        case .float: return .number
        case .boolean: return .number
        default: return self
        }
    }
}

struct Attribute {
    let name: String
    let attributeType: AttributeType
    var optional: Bool = false
    var hasDefaultValue: Bool = false
    var fullTypeName: String = ""
    var explicitUseScalar: Bool?
    
    mutating func genFullTypeName() {
        
        let resolvedType: AttributeType
        if let scalar = explicitUseScalar {
            if scalar {
                resolvedType = attributeType.toScalarType()
            } else {
                resolvedType = attributeType.toNonScalarType()
            }
        } else {
            resolvedType = attributeType
        }
        
        var typeName = resolvedType.toTypeName()
        
        if optional && !resolvedType.isScalarType() {
            // If it's a scalar type, we don't need to unwrap.
            if hasDefaultValue {
                typeName += "!"
            } else {
                typeName += "?"
            }
        }
        
        fullTypeName = typeName
    }
    
    init(name: String, type: AttributeType) {
        self.name = name
        self.attributeType = type
    }
}

struct Relationship {
    let name: String
    let destinationEntity: String
    
    var ordered: Bool = false
    var optional: Bool = false
    var toMany: Bool = false
    
    var fullTypeName: String = ""
    
    init(name: String, destinationEntity: String) {
        self.name = name
        self.destinationEntity = destinationEntity
    }
    
    mutating func genFullTypename() {
        var typeName: String
        
        if toMany {
            if ordered {
                typeName = "NSOrderedSet"
            } else {
                typeName = "Set<\(destinationEntity)>"
            }
        } else {
            typeName = destinationEntity
            
            if optional {
                typeName += "?"
            }
        }

        
        fullTypeName = typeName
    }
}
