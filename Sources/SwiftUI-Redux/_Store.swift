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
    
    @Published internal var state: State
    
    private let _getState: () -> State
    
    private let _dispatch: Dispatch
    
    private var disposables: Set<AnyDisposable> = []
    
    internal init<StoreType>(_ store: StoreType) where StoreType : StoreProtocol, StoreType.State == State {
        _getState = store.getState
        _dispatch = store.dispatch(_:)
        self.state = _getState()
        
        store.addObserver(Downstream(parent: self)).store(in: &disposables)
    }
    
    internal func getState() -> State {
        return _getState()
    }
    
    internal func dispatch(_ action: Action) {
        _dispatch(action)
    }
    
    internal func addObserver<O>(_ observer: O) -> Disposable where O : Observer, State == O.Value {
        let cancellable = $state.sink(receiveValue: observer.receive(_:))
        return AnyDisposable(cancellable.cancel)
    }
    
    func addObserver<O, S>(_ observer: O, transform: @escaping (Transform<State>) -> Transform<S>) -> Disposable where O : Observer, S == O.Value {
        let first = Transform<State>()
        transform(first).update{ observer.receive($1) }
        
        let cancellable = $state
            .scan(Optional<(State?, State)>.none) { ($0?.1, $1) }
            .compactMap { $0 }
            .sink(receiveValue: first.receive)
        return AnyDisposable(cancellable.cancel)
    }
}

extension _Store {
    
    private class Downstream : Observer {
        
        unowned var parent: _Store
        
        init(parent: _Store) {
            self.parent = parent
        }
        
        func receive(_ value: State) {
            parent.state = value
        }
    }
}
