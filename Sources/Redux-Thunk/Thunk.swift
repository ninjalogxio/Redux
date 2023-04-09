//
//  Thunk.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Redux

struct ThunkMiddleware<State> : Middleware {
    
    func handle(_ api: MiddlewareAPI<State>) -> (@escaping Dispatch) -> Dispatch {
        return { next in
            return { action in
                switch action {
                case let thunkAction as ThunkAction:
                    thunkAction.handle(api.getState, api.dispatch)
                default:
                    next(action)
                }
            }
        }
    }
}

public func createThunk<State>() -> AnyMiddleware<State> {
    return ThunkMiddleware<State>().eraseToAnyPublisher()
}
