//
//  Synchronized.swift
//  
//
//  Created by Kinglets on 2023/3/18.
//

import Foundation

@propertyWrapper internal struct Synchronized<Value> {
    
    private let _queue = DispatchQueue(label: "com.kinglets.redux.synchronized", attributes: .concurrent)
    
    private var _value: Value
    
    internal init(wrappedValue: Value) {
        self._value = wrappedValue
    }
    
    internal var wrappedValue: Value {
        get {
            return _queue.sync { _value }
        }
        set {
            _queue.sync(flags: .barrier) { _value = newValue }
        }
    }
    
}
