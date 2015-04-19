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
        if object is MapsUnderscoreCaseToCamelCase {
            key = camelCaseStringFromUnderscoreString(key)
        }
        if object.respondsToSelector(NSSelectorFromString(key)) {
            return key
        } else {
            return nil
        }
    }
    
    class func dictionaryKeyForPropertyKey(key: String, object: NSObject) -> String {
        if object is MapsUnderscoreCaseToCamelCase {
            return underscoreStringFromCamelCaseString(key)
        } else {
            return key
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
    
}

private let enumerationOptions = NSStringEnumerationOptions.ByComposedCharacterSequences