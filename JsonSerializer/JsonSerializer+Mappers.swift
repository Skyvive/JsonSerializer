//
//  JsonSerializer+Mappers.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

// MARK: JsonSerializer+Mappers

extension JsonSerializer {
    
    // MARK: Internal Methods
    
    class func mapperForType(type: Any.Type) -> JsonMapper? {
        return mapperFromCompleteDescription(completeDescription(type))
    }
    
    class func registerJsonMapper(mapper: JsonMapper) {
        for (index, existingMapper) in enumerate(mappers) {
            if "\(existingMapper.type)" == "\(mapper.type)" {
                mappers.removeAtIndex(index)
            }
        }
        mappers.append(mapper)
    }
    
    // MARK: Mapper Methods
    
    static var mappers: [JsonMapper] = [NSObjectMapper(), NSStringMapper(), NSNumberMapper(), NSArrayMapper(), NSDictionaryMapper(), OptionalMapper(), DictionaryMapper(), ArrayMapper(), StringMapper(), IntMapper(), FloatMapper(), DoubleMapper(), BoolMapper()]
    
    private class func mapperFromCompleteDescription(completeDescription: String) -> JsonMapper? {
        var typeDescription = self.typeDescription(completeDescription)
        if let jsonMapper = mapperFromTypeDescription(typeDescription) {
            if let genericMapper = jsonMapper as? JsonGenericMapper,
                let genericMappers = genericMappersFromGenericsDescription(genericsDescription(completeDescription))  {
                    genericMapper.submappers = genericMappers
            }
            if let jsonMapper = jsonMapper as? NSObjectMapper,
                let type = NSClassFromString(completeDescription) as? NSObject.Type {
                    jsonMapper.objectType = type
            }
            return jsonMapper
        }
        return nil
    }
    
    private class func mapperFromTypeDescription(typeDescription: String) -> JsonMapper? {
        for mapper in JsonSerializer.mappers {
            if self.typeDescription(mapper.type) == typeDescription {
                return mapper
            }
        }
        if let someClass: AnyClass = NSClassFromString(typeDescription) {
            return mapperFromSuperClass(someClass)
        }
        return nil
    }
    
    private class func mapperFromSuperClass(someClass: AnyClass) -> JsonMapper? {
        if let superclass: AnyClass = someClass.superclass() {
            for mapper in JsonSerializer.mappers {
                if typeDescription(superclass as! Any.Type) == typeDescription(mapper.type) {
                    return mapper
                }
            }
            return mapperFromSuperClass(superclass)
        } else {
            return nil
        }
    }
    
    private class func genericMappersFromGenericsDescription(genericsDescription: String) -> [JsonMapper]? {
        var generics = [JsonMapper]()
        for genericTypeDescription in componentsFromString(genericsDescription) {
            if let genericMapper = mapperFromCompleteDescription(genericTypeDescription) {
                generics.append(genericMapper)
            }
        }
        return generics
    }
    
    // MARK: String Functions
    
    private class func componentsFromString(string: String) -> [String] {
        var component = ""
        var components = [String]()
        var range = Range<String.Index>(start: string.startIndex, end: string.endIndex)
        var options = NSStringEnumerationOptions.ByComposedCharacterSequences
        var openings = 0
        var closings = 0
        string.enumerateSubstringsInRange(range, options: options) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if openings == closings && substring == "," {
                components.append(component)
                component = ""
            } else {
                if substring == ">" {
                    closings++
                }
                if substring == "<" {
                    openings++
                }
                component += substring
            }
        }
        components.append(component)
        return components
    }
    
    private class func completeDescription(type: Any.Type) -> String {
        return "\(type)".stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
    }
    
    private class func typeDescription(type: Any.Type) -> String {
        return typeDescription(completeDescription(type))
    }
    
    private class func typeDescription(description: String) -> String {
        if let openingRange = description.rangeOfString("<", options: nil, range: nil, locale: nil) where description[count(description) - 1] == ">" {
            return description.substringWithRange(Range<String.Index>(start: description.startIndex, end: openingRange.startIndex))
        } else {
            return description
        }
    }
    
    private class func genericsDescription(type: Any.Type) -> String {
        return genericsDescription(completeDescription(type))
    }
    
    private class func genericsDescription(description: String) -> String {
        if let openingRange = description.rangeOfString("<", options: nil, range: nil, locale: nil) where description[count(description) - 1] == ">" {
            return description.substringWithRange(Range<String.Index>(start: openingRange.endIndex, end: description.endIndex.predecessor()))
        } else {
            return ""
        }
    }
    
}