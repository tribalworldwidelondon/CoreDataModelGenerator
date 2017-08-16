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

enum GeneratorPropertiesError: Error {
    case missingOrMalformedPropertyKey(key: String)
}

struct GeneratorProperties {
    let templates: [GeneratorTemplateProperties]
    let dataModelPath: String
    let outputDirectory: String
    let templatePath: String
    
    static func fromDict(_ dict: [String: Any]) throws -> GeneratorProperties {
        guard let templatesArray = dict["templates"] as? [[String: Any]] else {
            throw GeneratorPropertiesError.missingOrMalformedPropertyKey(key: "templates")
        }
        
        guard let dataModelPath = dict["dataModelPath"] as? String else {
            throw GeneratorPropertiesError.missingOrMalformedPropertyKey(key: "dataModelPath")
        }
        
        guard let outputDirectory = dict["outputDirectory"] as? String else {
            throw GeneratorPropertiesError.missingOrMalformedPropertyKey(key: "outputDirectory")
        }
        
        guard let templatePath = dict["templatePath"] as? String else {
            throw GeneratorPropertiesError.missingOrMalformedPropertyKey(key: "templatePath")
        }
        
        let templates = try templatesArray.map { try GeneratorTemplateProperties.fromDict($0) }
        
        return GeneratorProperties(templates: templates,
                                   dataModelPath: dataModelPath,
                                   outputDirectory: outputDirectory,
                                   templatePath: templatePath)
    }
}

struct GeneratorTemplateProperties {
    let templateName: String
    let templateOutputFilePrefix: String
    let templateOutputFileSuffix: String
    let overwriteIfExists: Bool
    let outputSubdirectory: String
    
    static func fromDict(_ dict: [String: Any]) throws -> GeneratorTemplateProperties {
        guard let templateName = dict["templateName"] as? String else {
            throw GeneratorPropertiesError.missingOrMalformedPropertyKey(key: "templateName")
        }
        
        let templateOutputFilePrefix = dict["templateOutputFilePrefix"] as? String ?? ""
        let templateOutputFileSuffix = dict["templateOutputFileSuffix"] as? String ?? ""
        let overwriteIfExists = dict["overwriteIfExists"] as? Bool ?? false
        let outputSubdirectory = dict["outputSubdirectory"] as? String ?? ""
        
        return GeneratorTemplateProperties(templateName: templateName,
                                           templateOutputFilePrefix: templateOutputFilePrefix,
                                           templateOutputFileSuffix: templateOutputFileSuffix,
                                           overwriteIfExists: overwriteIfExists,
                                           outputSubdirectory: outputSubdirectory)
    }
}
