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
import AEXML

class CoreDataModelReader {
    let xmlDoc: AEXMLDocument
    var entities: [Entity] = []

    init(dataModelPath: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: dataModelPath))
        xmlDoc = try AEXMLDocument(xml: data, options: AEXMLOptions())
        
        parseEntities()
    }

    func parseEntities() {
        let xmlEntities = xmlDoc.root.children.filter { $0.name == "entity" }

        for entity in xmlEntities {
            entities.append(parseEntity(entity))
        }
    }
    
    func parseEntity(_ xmlEntity: AEXMLElement) -> Entity {
        var entity = Entity(name: xmlEntity.attributes["name"]!,
                            representedClassName: xmlEntity.attributes["representedClassName"]!)
        
        if xmlEntity.attributes["parentEntity"] != nil {
            entity.parentEntity = xmlEntity.attributes["parentEntity"]
        }
        
        let xmlEntityAttributes = xmlEntity.children.filter { $0.name == "attribute" }
        let xmlEntityRelationships = xmlEntity.children.filter { $0.name == "relationship" }
        
        entity.attributes = xmlEntityAttributes.map { parseAttribute($0) }.sorted { $0.name < $1.name }
        entity.relationships = xmlEntityRelationships.map { parseRelationship($0) }.sorted { $0.name < $1.name }
        
        return entity
    }
    
    func parseAttribute(_ xmlAttribute: AEXMLElement) -> Attribute {
        var attribute = Attribute(name: xmlAttribute.attributes["name"]!,
                                  type: AttributeType.fromString(xmlAttribute.attributes["attributeType"]!))
        
        attribute.optional = xmlAttribute.attributes["optional"] == "YES"
        attribute.hasDefaultValue = xmlAttribute.attributes["defaultValueString"] != nil
        
        if let scalar = xmlAttribute.attributes["usesScalarValueType"] {
            attribute.explicitUseScalar = scalar == "YES"
        }
        
        attribute.genFullTypeName()
        
        return attribute
    }
    
    func parseRelationship(_ xmlRelationship: AEXMLElement) -> Relationship {
        var relationship = Relationship(name: xmlRelationship.attributes["name"]!,
                                        destinationEntity: xmlRelationship.attributes["destinationEntity"]!)
        
        relationship.optional = xmlRelationship.attributes["optional"] == "YES"
        relationship.toMany = xmlRelationship.attributes["toMany"] == "YES"
        relationship.ordered = xmlRelationship.attributes["ordered"] == "YES"
        
        relationship.genFullTypename()
        
        return relationship
 }

}
