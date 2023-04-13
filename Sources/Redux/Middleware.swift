//
//  Middleware.swift
//  
//
//  Created by Kinglets on 2023/3/18.
//

import Foundation

public typealias MiddlewareAPI<State> = (
    getState: () -> State,
    dispatch: Dispatch
)

public protocol Middleware {
    
    associatedtype State
    
    func handle(_ api: MiddlewareAPI<State>) -> (_ next: @escaping Dispatch) -> Dispatch
}

extension Middleware {
    
    public func callAsFunction(_ api: MiddlewareAPI<State>) -> (_ next: @escaping Dispatch) -> Dispatch {
        return handle(api)
    }
    
    public func eraseToAnyMiddleware() -> AnyMiddleware<State> {
        return AnyMiddleware(handle)
    }
}

public struct AnyMiddleware<State> : Middleware {
    
    private let _handler: (_ api: MiddlewareAPI<State>) -> (_ next: @escaping Dispatch) -> Dispatch
    
    public init(_ handler: @escaping (_: MiddlewareAPI<State>) -> (_ next: @escaping Dispatch) -> Dispatch) {
        _handler = handler
    }
    
    public func handle(_ api: MiddlewareAPI<State>) -> (@escaping Dispatch) -> Dispatch {
        return _handler(api)
    }
}
