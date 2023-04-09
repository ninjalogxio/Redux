//
//  Logger.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Redux

struct CreateLogger<State> : Middleware {
    
    func handle(_ api: MiddlewareAPI<State>) -> (@escaping Dispatch) -> Dispatch {
        return { next in
            return { action in
                print("will dispatch: \(action)")
                next(action)
                print("state after dispatch: \(api.getState())")
            }
        }
    }
}

public func createLogger<State>() -> AnyMiddleware<State> {
    return CreateLogger().eraseToAnyPublisher()
}
