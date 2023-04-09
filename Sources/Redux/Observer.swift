//
//  Observer.swift
//  
//
//  Created by Kinglets on 2023/3/18.
//

import Foundation

public protocol Observer {
    
    associatedtype Value
    
    func receive(_ value: Value)
}

public struct AnyObserver<Value> : Observer {
    
    private let _receive: (Value) -> Void
    
    public init(receive: @escaping (Value) -> Void) {
        _receive = receive
    }
    
    public func receive(_ value: Value) {
        _receive(value)
    }
}
