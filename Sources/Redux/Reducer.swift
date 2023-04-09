//
//  Reducer.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Foundation

public protocol Reducer {
    
    associatedtype State
    
    func handle(_ state: State, _ action: Action) -> State
}

extension Reducer {
    
    public func callAsFunction(_ state: State, _ action: Action) -> State {
        handle(state, action)
    }
}

public struct AnyReducer<State> : Reducer {
    
    private let _handler: (State, Action) -> State
    
    public init(_ handler: @escaping (State, Action) -> State) {
        _handler = handler
    }
    
    public func handle(_ state: State, _ action: Action) -> State {
        return _handler(state, action)
    }
}
