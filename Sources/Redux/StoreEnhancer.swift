//
//  StoreEnhancer.swift
//  
//
//  Created by Kinglets on 2023/3/18.
//

import Foundation

public typealias StoreEnhancer<State> = (
    _ getState: @escaping () -> State,
    _ dispatch: @escaping Dispatch
) -> Dispatch


public func applyMiddleware<State>(_ middlewares: AnyMiddleware<State>...) -> StoreEnhancer<State> {
    
    return {
        let store = (getState: $0, dispatch: $1)
        
        var dispatch: Dispatch = { _ in
            fatalError("Dispatching while constructing your middleware is not allowed. "
                       + "Other middleware would not be applied to this dispatch.")
        }
        
        let middlewareAPI: MiddlewareAPI<State> = (
            getState: store.getState,
            dispatch: { dispatch($0) }
        )
        
        dispatch = middlewares
            .reversed()
            .reduce(store.dispatch) { dispatchFunction, middleware in
                return middleware(middlewareAPI)(dispatchFunction)
            }
        return dispatch
    }
}
