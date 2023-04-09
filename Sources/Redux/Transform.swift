//
//  Transform.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Foundation

public class Transform<State> {
    
    private var _receive: (State?, State) -> Void = { _, _ in }
    
    public init() {
    }
    
    public init(receive: @escaping (State?, State) -> Void) {
        _receive = receive
    }
    
    public func update(_ receive: @escaping (State?, State) -> Void) {
        _receive = receive
    }
    
    public func receive(oldState: State?, newState: State) {
        _receive(oldState, newState)
    }
    
    public init(sink: (_ receive: @escaping (State?, State) ->Void) -> Void) {
        sink {
            self.receive(oldState: $0, newState: $1)
        }
    }
    
    public func select<S>(_ selector: @escaping (State) -> S) -> Transform<S> {
        return Transform<S> { receive in
            update {
                receive($0.map(selector) ?? nil, selector($1))
            }
        }
    }
    
    public func select<S>(_ keyPath: KeyPath<State, S>) -> Transform<S> {
        select { $0[keyPath: keyPath] }
    }
    
    public func removeDuplicates(_ predicate: @escaping (State, State) -> Bool) -> Transform<State> {
        return Transform<State> { receive in
            update {
                switch ($0, $1) {
                case let(old?, new):
                    if !predicate(old, new) {
                        receive($0, $1)
                    }
                default:
                    receive($0, $1)
                }
            }
        }
    }
    
    public func removeDuplicates() -> Transform<State> where State : Equatable {
        return removeDuplicates(==)
    }
}
