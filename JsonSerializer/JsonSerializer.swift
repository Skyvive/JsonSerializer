//
//  JsonSerializer.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

/// To automatically map underscore json keys to camel case property keys,
/// implement the MapsUnderscoreToCamelCase protocol
public protocol MapsUnderscoreCaseToCamelCase {}

/// To provide your own custom key mapping, implement the MapsCustomKeys protocol
public protocol MapsCustomKeys {
    
    /// Provide the json keys followed by their property names
    /// e.g. ["is_public":"public", "another_json_property":"aJsonProperty"]
    var keyMapping: [String : String] { get }
    
}

/// Implement this protocol to specify properties that you want to be ignored
public protocol IgnoresKeys {
    
    var ignoredKeys: [String] { get }
    
}

public class JsonSerializer {
    
    /// Sets an object's properties with contents of dictionary
    public class func loadDictionary(dictionary: NSDictionary, intoObject object: NSObject) {
        loadJsonDictionary(dictionary, intoObject: object)
    }
    
    /// Returns a serialized dictionary from an object
    public class func dictionaryFrom(object: NSObject) -> NSDictionary {
        return jsonDictionaryFromObject(object)
    }
    
    /// Call this method to register a custom JsonMapper
    public class func registerMapper(mapper: JsonMapper) {
        registerJsonMapper(mapper)
    }
    
}