//
//  JsonSerializer.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

public protocol MapsUnderscoreCaseToCamelCase {}

public class JsonSerializer {
    
    // Sets an object's properties with contents of dictionary
    public class func loadDictionary(dictionary: NSDictionary, intoObject object: NSObject) {
        loadJsonDictionary(dictionary, intoObject: object)
    }
    
    // Returns a serialized dictionary from an object
    public class func dictionaryFrom(object: NSObject) -> NSDictionary {
        return jsonDictionaryFromObject(object)
    }
    
    // Call this method to register a custom JsonMapper
    public class func registerMapper(mapper: JsonMapper) {
        registerJsonMapper(mapper)
    }
    
}