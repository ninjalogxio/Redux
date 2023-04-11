//
//  _Store.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

internal class _Store<State> : ObservableObject, StoreProtocol {
    
    private let _getState: () -> State
    
    private let _dispatch: (Action) -> Void
    
    private let _removeDuplicates: Bool
    
    internal init<StoreType>(_ store: StoreType, removeDuplicates: Bool = true) where StoreType : StoreProtocol, StoreType.State == State {
        _getState = store.getState
        _dispatch = store.dispatch
        
        _removeDuplicates = removeDuplicates
    }
    
    internal func getState() -> State {
        return _getState()
    }
    
    internal func dispatch(_ action: Action) {
        let oldValue = _getState()
        _dispatch(action)
        let newValue = _getState()
        
        valueChange(oldValue: oldValue, newValue: newValue)
    }
}

extension _Store {
    
    func valueChange(oldValue: State, newValue: State) {
        objectWillChange.send()
    }
    
    func valueChange(oldValue: State, newValue: State) where State : Equatable {
        if !_removeDuplicates || oldValue != newValue {
            objectWillChange.send()
        }
    }
}
