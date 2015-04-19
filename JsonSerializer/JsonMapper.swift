//
//  JsonMapper.swift
//  JsonSerializer
//
//  Created by Bradley Hilton on 4/18/15.
//  Copyright (c) 2015 Skyvive. All rights reserved.
//

import Foundation

public protocol JsonMapper {
    
    // Required read-only property that returns the mapper type
    var type: Any.Type { get }
    
    // Required method that returns an instance of this mapper's type given a JsonValue input
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject?
    
    // Required method that returns a JsonValue given an instance of this mapper's type
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue?
    
}