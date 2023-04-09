//
//  ThunkAction.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Redux

public protocol ThunkAction : Action {
        
    func handle<State>(_ getState: @escaping () -> State, _ dispatch: @escaping Dispatch)
}
