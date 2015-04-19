//
//  JsonSerializer+Deserialization.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

// MARK: JsonObject+Initialization

extension JsonSerializer {
    
    class func loadJsonDictionary(dictionary: NSDictionary, intoObject object: NSObject) {
        for (key, value) in dictionary {
            if let key = key as? String,
                let mappedKey = propertyKeyForDictionaryKey(key, object: object),
                let mappedValue: AnyObject = valueForValue(value, key: mappedKey, object: object) {
                    object.setValue(mappedValue, forKey: mappedKey)
            }
        }
    }
    
    private class func valueForValue(value: AnyObject, key: String, object: NSObject) -> AnyObject? {
        for (propertyName, mirrorType) in properties(object) {
            if propertyName == key {
                if let mapper = mapperForType(mirrorType.valueType), let jsonValue = JsonValue(value: value) {
                    return mapper.propertyValueFromJsonValue(jsonValue)
                }
            }
        }
        return nil
    }
    
    class func properties(object: NSObject) -> [(String, MirrorType)] {
        var properties = [(String, MirrorType)]()
        for i in 1..<reflect(object).count {
            properties.append(reflect(object)[i])
        }
        return properties
    }
    
}