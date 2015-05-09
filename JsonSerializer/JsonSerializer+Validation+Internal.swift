//
//  JsonSerializer+Validation.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 5/9/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

extension JsonSerializer {
    
    /// Returns required object keys missing from a dictionary
    class func requiredKeysMissingFromJsonDictionary(dictionary: NSDictionary, forObject object: NSObject) -> [String] {
        if let validatesImplicitlyUnwrappedOptionals = object as? ValidateImplicitlyUnwrappedOptionals {
            return missingKeysForDictionary(dictionary, object: object, requiredKeys: requiredKeys(validatesImplicitlyUnwrappedOptionals))
        } else if let validatesRequiredKeys = object as? ValidatesRequiredKeys {
            return missingKeysForDictionary(dictionary, object: object, requiredKeys: validatesRequiredKeys.requiredKeys)
        } else if let validatesOptionalKeys = object as? ValidatesOptionalKeys {
            return missingKeysForDictionary(dictionary, object: object, requiredKeys: requiredKeys(validatesOptionalKeys))
        } else {
            return [String]()
        }
    }
    
    private class func requiredKeys(object: ValidateImplicitlyUnwrappedOptionals) -> [String] {
        var requiredKeys = [String]()
        for (name, mirrorType) in properties(object) {
            if let object = object as? NSObject where object.respondsToSelector(NSSelectorFromString(name)) && mirrorType.summary == "nil" {
                if let mapper = mapperForType(mirrorType.valueType),
                    let optionalMapper = mapper as? OptionalMapper,
                    let sampleInstance: AnyObject = optionalMapper.sampleInstance as? AnyObject {
                        object.setValue(sampleInstance, forKey: name)
                        if object.valueForKey(name) != nil && isLeafProperty(name: name, object: object) {
                            requiredKeys.append(name)
                        }
                        object.setValue(nil, forKey: name)
                }
            }
        }
        return requiredKeys
    }
    
    private class func isLeafProperty(#name: String, object: Any) -> Bool {
        for (propertyName, mirrorType) in properties(object) {
            if propertyName == name {
                return "\(mirrorType)".rangeOfString("Swift._OptionalMirror", options: nil, range: nil, locale: nil) == nil
            }
        }
        return false
    }
    
    private class func requiredKeys(object: ValidatesOptionalKeys) -> [String] {
        var requiredKeys = [String]()
        for (name, mirrorType) in properties(object) {
            requiredKeys.append(name)
            for optionalKey in object.optionalKeys {
                if name == optionalKey && requiredKeys.count > 0 {
                    requiredKeys.removeLast()
                }
            }
        }
        return requiredKeys
    }
    
    private class func missingKeysForDictionary(dictionary: NSDictionary, object: NSObject, requiredKeys: [String]) -> [String] {
        var missingKeys = [String]()
        for key in requiredKeys {
            if let key = dictionaryKeyForPropertyKey(key, object: object) where dictionary[key] == nil {
                missingKeys.append(key)
            }
        }
        return missingKeys
    }
    
    /// Returns required object keys missing from an already serialized object
    class func requiredKeysMissingFromSerializedObject(object: NSObject) -> [String] {
        if let validatesImplicitlyUnwrappedOptionals = object as? ValidateImplicitlyUnwrappedOptionals {
            return missingKeysForObject(object, requiredKeys: requiredKeys(validatesImplicitlyUnwrappedOptionals))
        } else if let validatesRequiredKeys = object as? ValidatesRequiredKeys {
            return missingKeysForObject(object, requiredKeys: validatesRequiredKeys.requiredKeys)
        } else if let validatesOptionalKeys = object as? ValidatesOptionalKeys {
            return missingKeysForObject(object, requiredKeys: requiredKeys(validatesOptionalKeys))
        } else {
            return [String]()
        }
    }
    
    private class func missingKeysForObject(object: NSObject, requiredKeys: [String]) -> [String] {
        var missingKeys = [String]()
        for key in requiredKeys {
            for (name, mirrorType) in properties(object) {
                if name == key && mirrorType.summary == "nil" {
                    missingKeys.append(key)
                }
            }
        }
        return missingKeys
    }
    
}