# CoreDataModelGenerator

A customisable utility for generating NSManagedObject subclasses for CoreData entities in Swift.

### Rationale

The XCode provided code generator has a couple of problems when working with Swift code:

* Non-optional properties still get generated as optional types
* Relationships are generated as non-generic NSSet variables.

This generator overcomes these problems, while providing complete control over the content and layout of the generated files. It does this by using the Stencil templating library.

## Building

Simply check out out the project and run the provided install.sh script. This will install CoreDataModelGenerator to `/usr/local/bin`

	git clone https://github.com/tribalworldwidelondon/CoreDataModelGenerator.git
	cd CoreDataModelGenerator
	./install.sh

## Config

CoreDataModelGenerator requires a configuration file. Here is an example:

```
{
    "templates": [
        {
            "templateName": "CoreDataClass.stencil",
            "templateOutputFileSuffix": "+CoreDataClass",
            "overwriteIfExists": false,
            "outputSubdirectory": ""
        },
        {
            "templateName": "CoreDataProperties.stencil",
            "templateOutputFileSuffix": "+CoreDataProperties",
            "overwriteIfExists": true,
            "outputSubdirectory": "generatedExtensions"
        }
    ],
    "dataModelPath": "./myDataModel.xcdatamodel",
    "outputDirectory": "./output",
    "templatePath": "./templates"
}
```

### Configuration Format

| Property          | Description 	                                                        |
|-------------------|-----------------------------------------------------------------------|
| `templates`       | An array containing objects describing the templates to be used       |
| `dataModelPath`   | The path to the xcdatamodel to use                                    |
| `outputDirectory` | The base directory where the generated source files will be output    |
| `templatePath`    | The path to the directory containing the Stencil templates to be used |

#### Template Object

| Property                                           | Description                                      |
|----------------------------------------------------|--------------------------------------------------|
| `templateName`                                     | The name of the template file to use             |
| `templateOutputFilePrefix` *(optional)*            | The prefix to use in the output file name.       |
| `templateOutputFileSuffix` *(optional)*            | The suffix to use in the output file name.       |
| `overwriteIfExists` *(optional)* *default = false* | Overwrite the output file if it already exists   |
| `outputSubdirectory` *(optional)*                  | The subdirectory to write the generated file to. |

## Usage

	CoreDataModelGenerator config.json