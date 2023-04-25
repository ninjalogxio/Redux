//
//  ThunkAction.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Redux

public struct ThunkAction<State> : Action {
    
    public let _handler: (@escaping () -> State, @escaping Dispatch) -> Void
    
    public init(_ handler: @escaping (_ getState: @escaping () -> State, _ dispatch: @escaping Dispatch) -> Void) {
        _handler = handler
    }
    
    func handle(_ getState: @escaping () -> State, _ dispatch: @escaping Dispatch) {
        _handler(getState, dispatch)
    }
}
