//
//  _Store.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

internal class _Store<StoreType> : ObservableObject, StoreProtocol where StoreType : StoreProtocol {
    
    public typealias State = StoreType.State
    
    private let _store: StoreType
    
    private let _removeDuplicates: Bool
    
    internal init(_ store: StoreType, removeDuplicates: Bool = true) {
        _store = store
        _removeDuplicates = removeDuplicates
    }
    
    internal func getState() -> State {
        return _store.getState()
    }
    
    internal func addObserver<O>(_ observer: O) -> Disposable where O : Observer, State == O.Value {
        return _store.addObserver(observer)
    }
    
    internal func addObserver<O, S>(_ observer: O, transform: @escaping (Transform<State>) -> Transform<S>) -> Disposable where O : Observer, S == O.Value {
        return _store.addObserver(observer, transform: transform)
    }
}

extension _Store {
    
    internal func dispatch(_ action: Action) {
        _store.dispatch(action)
        objectWillChange.send()
    }
}

extension _Store where State : Equatable {
    
    internal func dispatch(_ action: Action) {
        let oldValue = _store.getState()
        _store.dispatch(action)
        let newValue = _store.getState()
        
        if !_removeDuplicates || oldValue != newValue {
            objectWillChange.send()
        }
    }
}
