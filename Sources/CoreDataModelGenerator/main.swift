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
import Stencil
import PathKit
import Commander
import StencilSwiftKit

func generateFile(forEntity entity: Entity, withTemplatePath path: Path, templateName: String) throws -> String {
    var environment = stencilSwiftEnvironment()
    environment.loader = FileSystemLoader(paths: [path])
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    
    let context: [String: Any] = [
        "entity": entity,
        "date": dateFormatter.string(from: Date()),
        "year": Calendar.current.component(.year, from: Date())
    ]
    
    let rendered = try environment.renderTemplate(name: templateName, context: context)
    return rendered
}

func generateFiles(forEntity entity: Entity,
                   withTemplatePath path: Path,
                   templateNames: [String]) throws -> [String: String] {
    return try zip(templateNames, templateNames.map {
        try generateFile(forEntity: entity, withTemplatePath: path, templateName: $0)
    }).reduce([String: String]()) {
        var dict = $0
        dict[$1.0] = $1.1
        return dict
    }
}

func generateTemplates(forDataModelWithPath dataModelPath: String, templatePath: Path, templateNames: [String]) throws -> [String: [String: String]] {
    let model = try CoreDataModelReader(dataModelPath: "\(dataModelPath)/contents")
    
    let entityNames = model.entities.map { $0.name }
    let entityFiles: [[String: String]] = try model.entities.map {
        print("Generating files for entity \($0.representedClassName)")
        return try generateFiles(forEntity: $0, withTemplatePath: templatePath, templateNames: templateNames)
    }
    
    return zip(entityNames, entityFiles).reduce([String: [String: String]]()) {
        var dict = $0
        dict[$1.0] = $1.1
        return dict
    }
}

func generateFiles(properties: GeneratorProperties) {
    let templates: [String: [String: String]]
    
    do {
        templates = try generateTemplates(forDataModelWithPath: properties.dataModelPath,
                                                  templatePath: Path(properties.templatePath),
                                                  templateNames: properties.templates.map { $0.templateName })
    } catch {
        generatorError("Unable to generate file: \(String(describing: error))")
    }
        
    for template in templates {
        let entityName = template.key
        let entityFileTemplates = template.value
        
        for (templateName, contents) in entityFileTemplates {
            let templateProperties = properties.templates.filter { $0.templateName == templateName }.first!
            
            let fileName = templateProperties.templateOutputFilePrefix
                + entityName
                + templateProperties.templateOutputFileSuffix
                + ".swift"
            
            var outputFilePath = "\(properties.outputDirectory)"
            
            if templateProperties.outputSubdirectory.count > 0 {
                outputFilePath += "/\(templateProperties.outputSubdirectory)"
            }
            
            // Create the output directory if it doesn't exist
            
            do {
                try FileManager.default.createDirectory(atPath: outputFilePath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                generatorError("Unable to create output directory: \(error.localizedDescription)")
            }
            
            outputFilePath += "/\(fileName)"
            
            let outputURL = URL(fileURLWithPath: outputFilePath)
            
            let fileExists = FileManager.default.fileExists(atPath: outputURL.path)
            
            // Write the file out if it doesn't exist or if it is set to be overwritten
            if templateProperties.overwriteIfExists || !fileExists {
                do {
                    try contents.write(toFile: outputURL.path, atomically: false, encoding: .utf8)
                } catch {
                    generatorError("Unable to write to file path \(outputURL.path): \(error.localizedDescription)")
                }
            }
        }
    }
}

func generatorError(_ msg: String) -> Never {
    print(msg)
    exit(1)
}

let main = command ( Argument<String>("configFilePath", description: "The path to the configuration file") ) { configFilePath in
    // Parse the properties
    
    guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: configFilePath)) else {
        generatorError("Error: Unable to load configuration file at path \(configFilePath)")
    }
    
    guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
        generatorError("Error: Configuration file is not valid JSON")
    }
    
    guard let jsonDict = jsonObject as? [String: Any] else {
        generatorError("Error: Configuration file is not in the correct format")
    }
    
    do {
        let properties = try GeneratorProperties.fromDict(jsonDict)
        generateFiles(properties: properties)
    } catch GeneratorPropertiesError.missingOrMalformedPropertyKey(let key) {
        generatorError("Error: Missing or malformed key '\(key)' in configuration file")
    }
}

main.run()

