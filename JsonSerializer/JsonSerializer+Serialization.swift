//
//  JsonSerializer+Serialization.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

// MARK: JsonObject+Serialization

extension JsonSerializer {
    
    class func jsonDictionaryFromObject(object: NSObject) -> NSDictionary {
        var dictionary = NSMutableDictionary()
        for (name, mirrorType) in properties(object) {
            if let mapper = mapperForType(mirrorType.valueType),
                let value: AnyObject = valueForProperty(name, mirrorType: mirrorType, object: object) {
                    if let jsonValue = mapper.jsonValueFromPropertyValue(value) {
                        dictionary.setObject(jsonValue.value(), forKey: dictionaryKeyForPropertyKey(name, object: object))
                    }
            }
        }
        return dictionary
    }
    
    private class func valueForProperty(name: String, mirrorType: MirrorType, object: NSObject) -> AnyObject? {
        if let value: AnyObject = mirrorType.value as? AnyObject {
            return value
        } else if object.respondsToSelector(NSSelectorFromString(name)) {
            if let value: AnyObject = object.valueForKey(name) {
                return value
            }
        }
        return nil
    }
    
}