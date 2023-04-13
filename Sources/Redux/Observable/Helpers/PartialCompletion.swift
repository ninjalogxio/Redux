//
//  PartialCompletion.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

internal enum PartialCompletion<Value> {
    
    case `continue`(Value)
    
    case finished
}

extension PartialCompletion where Value == Void {
    
    internal static var `continue`: PartialCompletion {
        return .continue(())
    }
}
