//
//  Mappers.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

// MARK: NSObject Mapper

class NSObjectMapper: JsonMapper {
    
    var objectType: NSObject.Type = NSObject.self
    
    var type: Any.Type { return NSObject.self }
    
    var sampleInstance: Any { return objectType() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary):
            let object = objectType()
            JsonSerializer.loadDictionary(nsdictionary, intoObject: object)
            return object
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let object = value as? NSObject {
            return JsonValue(value: JsonSerializer.dictionaryFrom(object))
        } else {
            return nil
        }
    }
    
}

// MARK: Foundation Mappers

class NSStringMapper: JsonMapper {
    
    var type: Any.Type { return NSString.self }
    
    var sampleInstance: Any { return NSString() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .String(let nsstring): return nsstring
        case .Number(let nsnumber): return nsnumber.stringValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
}

class NSNumberMapper: JsonMapper {
    
    var type: Any.Type { return NSNumber.self }
    
    var sampleInstance: Any { return NSNumber(integer: 0) }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber
        case .String(let nsstring): return nsstring
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class NSArrayMapper: JsonMapper {
    
    var type: Any.Type { return NSArray.self }
    
    var sampleInstance: Any { return NSArray() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Array(let nsarray): return nsarray
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class NSDictionaryMapper: JsonMapper {
    
    var type: Any.Type { return NSDictionary.self }
    
    var sampleInstance: Any { return NSDictionary() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary): return nsdictionary
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

// MARK: Generic Mappers

class JsonGenericMapper: JsonMapper {
    
    var submappers = [JsonMapper]()
    
    var type: Any.Type { return JsonGenericMapper.self }
    
    var sampleInstance: Any { return JsonGenericMapper() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? { return nil }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: nil) }
    
}

class OptionalMapper: JsonGenericMapper {
    
    override var type: Any.Type { return Optional<AnyObject>.self }
    
    override var sampleInstance: Any { return submappers[0].sampleInstance }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        if submappers.count > 0 {
            return submappers[0].propertyValueFromJsonValue(value)
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if submappers.count > 0 {
            return submappers[0].jsonValueFromPropertyValue(value)
        } else {
            return nil
        }
    }
    
}

class DictionaryMapper: JsonGenericMapper {
    
    override var type: Any.Type { return Dictionary<String, AnyObject>.self }
    
    override var sampleInstance: Any { return NSDictionary() }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary): return propertyValueFromDictionary(nsdictionary)
        default: return nil
        }
    }
    
    private func propertyValueFromDictionary(nsdictionary: NSDictionary) -> AnyObject? {
        if submappers.count > 1 {
            let keyMapper = submappers[0]
            let valueMapper = submappers[1]
            var dictionary = NSMutableDictionary()
            for (key, value) in nsdictionary {
                if let keyJsonValue = JsonValue(value: key),
                    let valueJsonValue = JsonValue(value: value),
                    let key: NSCopying = keyMapper.propertyValueFromJsonValue(keyJsonValue) as? NSCopying,
                    let value: AnyObject = valueMapper.propertyValueFromJsonValue(valueJsonValue) {
                        dictionary.setObject(value, forKey: key)
                }
            }
            return dictionary
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let valueDictionary = value as? NSDictionary where submappers.count > 1 {
            let keyMapper = submappers[0]
            let valueMapper = submappers[1]
            var dictionary = NSMutableDictionary()
            for (key, value) in valueDictionary {
                if let keyJsonObject = keyMapper.jsonValueFromPropertyValue(key),
                    let key = keyJsonObject.value() as? NSCopying,
                    let valueJsonValue = valueMapper.jsonValueFromPropertyValue(value) {
                        dictionary.setObject(valueJsonValue.value(), forKey: key)
                }
            }
            return JsonValue(value: dictionary)
        } else {
            return nil
        }
    }
}

class ArrayMapper: JsonGenericMapper {
    
    override var type: Any.Type { return Array<AnyObject>.self }
    
    override var sampleInstance: Any { return [submappers[0].sampleInstance] }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Array(let nsarray): return propertyValueFromArray(nsarray)
        default: return nil
        }
    }
    
    private func propertyValueFromArray(nsarray: NSArray) -> AnyObject? {
        if submappers.count > 0 {
            let submapper = submappers[0]
            var array = NSMutableArray()
            for value in nsarray {
                if let jsonValue = JsonValue(value: value),
                    let object: AnyObject = submapper.propertyValueFromJsonValue(jsonValue) {
                        array.addObject(object)
                }
            }
            return array
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let valueArray = value as? NSArray where submappers.count > 0 {
            let submapper = submappers[0]
            var array = NSMutableArray()
            for value in valueArray {
                if let jsonObject = submapper.jsonValueFromPropertyValue(value) {
                    array.addObject(jsonObject.value())
                }
            }
            return JsonValue(value: array)
        } else {
            return nil
        }
    }
}

// MARK: Swift Mappers

class StringMapper: JsonMapper {
    
    var type: Any.Type { return String.self }
    
    var sampleInstance: Any { return String() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .String(let nsstring): return nsstring
        case .Number(let nsnumber): return nsnumber.stringValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class IntMapper: JsonMapper {
    
    var type: Any.Type { return Int.self }
    
    var sampleInstance: Any { return Int() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.integerValue
        case .String(let nsstring): return nsstring.integerValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Int {
            return JsonValue(value: NSNumber(integer: value))
        } else {
            return nil
        }
    }
    
}

class FloatMapper: JsonMapper {
    
    var type: Any.Type { return Float.self }
    
    var sampleInstance: Any { return Float() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.floatValue
        case .String(let nsstring): return nsstring.floatValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Float {
            return JsonValue(value: NSNumber(float: value))
        } else {
            return nil
        }
    }
    
}

class DoubleMapper: JsonMapper {
    
    var type: Any.Type { return Double.self }
    
    var sampleInstance: Any { return Double() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.doubleValue
        case .String(let nsstring): return nsstring.doubleValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Double {
            return JsonValue(value: NSNumber(double: value))
        } else {
            return nil
        }
    }
    
}

class BoolMapper: JsonMapper {
    
    var type: Any.Type { return Bool.self }
    
    var sampleInstance: Any { return Bool() }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.boolValue
        case .String(let nsstring): return nsstring.boolValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Bool {
            return JsonValue(value: NSNumber(bool: value))
        } else {
            return nil
        }
    }
    
}

