//
//  JsonSerializer+KeyMapping.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

// MARK: JsonSerializer+KeyMapping

extension JsonSerializer {
    
    class func propertyKeyForDictionaryKey(var key: String, object: NSObject) -> String? {
        if let object = object as? MapsCustomKeys,
            let propertyKey = object.keyMapping[key] {
            key = propertyKey
        } else if object is MapsUnderscoreCaseToCamelCase {
            key = camelCaseStringFromUnderscoreString(key)
        }
        if object.respondsToSelector(NSSelectorFromString(key)) && !anObject(object, ignoresKey: key) {
            return key
        } else {
            return nil
        }
    }
    
    class func dictionaryKeyForPropertyKey(key: String, object: NSObject) -> String? {
        if anObject(object, ignoresKey: key) {
            return nil
        } else {
            if let object = object as? MapsCustomKeys {
                for (dictionaryKey, propertyKey) in object.keyMapping {
                    if propertyKey == key {
                        return dictionaryKey
                    }
                }
            }
            if object is MapsUnderscoreCaseToCamelCase {
                return underscoreStringFromCamelCaseString(key)
            } else {
                return key
            }
        }
    }
    
    private class func camelCaseStringFromUnderscoreString(underscoreString: String) -> String {
        var camelCaseString = ""
        var makeNextCharacterUppercase = false
        underscoreString.enumerateSubstringsInRange(rangeForString(underscoreString), options: enumerationOptions) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if substring == "_" {
                makeNextCharacterUppercase = true
            } else if makeNextCharacterUppercase {
                camelCaseString += substring.uppercaseString
                makeNextCharacterUppercase = false
            } else {
                camelCaseString += substring
            }
        }
        return camelCaseString
    }
    
    private class func underscoreStringFromCamelCaseString(camelCaseString: String) -> String {
        var underscoreString = ""
        camelCaseString.enumerateSubstringsInRange(rangeForString(camelCaseString), options: enumerationOptions) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if substring.lowercaseString != substring {
                underscoreString += "_" + substring.lowercaseString
            } else {
                underscoreString += substring
            }
        }
        return underscoreString
    }
    
    private class func rangeForString(string: String) -> Range<String.Index> {
        return Range<String.Index>(start: string.startIndex, end: string.endIndex)
    }
    
    private class func anObject(object: NSObject, ignoresKey: String) -> Bool {
        for key in ignoredPropertyKeysForObject(object) {
            if key == ignoresKey {
                return true
            }
        }
        return false
    }
    
    private class func ignoredPropertyKeysForObject(object: NSObject) -> [String] {
        var ignoredPropertyKeys = ["super", "keyMapping", "ignoredKeys", "requiredKeys", "optionalKeys"]
        if let object = object as? IgnoresKeys {
            ignoredPropertyKeys += object.ignoredKeys
        }
        return ignoredPropertyKeys
    }
    
}

private let enumerationOptions = NSStringEnumerationOptions.ByComposedCharacterSequences