//
//  JsonSerializer+Validation.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 5/9/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

/// To validate implicitly unwrapped optionals implement this protocol
/// Note: You only should implement one of the validation protocols
public protocol ValidateImplicitlyUnwrappedOptionals {}

/// To validate required keys you specify, implement this protocol
/// Note: You only should implement one of the validation protocols
public protocol ValidatesRequiredKeys {
    
    /// Return a list of required keys e.g. ["id", "isPublic"]
    var requiredKeys: [String] { get }
    
}

/// To validate all but optional keys that you specify, implement this protocol
/// Note: You only should implement one of the validation protocols
public protocol ValidatesOptionalKeys {
    
    /// Return a list of optional keys e.g. ["friends", "favoriteColor"]
    var optionalKeys: [String] { get }
    
}

extension JsonSerializer {
    
    /// Returns true if dictionary contains object's required keys
    public class func validateDictionary(dictionary: NSDictionary, forObject: NSObject) -> Bool {
        return requiredKeysMissingFromDictionary(dictionary, forObject: forObject).count == 0
    }
    
    /// Returns required object keys missing from a dictionary
    public class func requiredKeysMissingFromDictionary(dictionary: NSDictionary, forObject: NSObject) -> [String] {
        return requiredKeysMissingFromJsonDictionary(dictionary, forObject: forObject)
    }
    
    /// Returns true if object's required keys are not nil
    public class func validateObject(object: NSObject) -> Bool {
        return requiredKeysMissingFromObject(object).count == 0
    }
    
    /// Returns required object keys missing from an already serialized object
    public class func requiredKeysMissingFromObject(object: NSObject) -> [String] {
        return requiredKeysMissingFromSerializedObject(object)
    }
    
}