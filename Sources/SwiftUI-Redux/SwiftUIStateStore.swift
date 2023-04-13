//
//  SwiftUIStateStore.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

public final class SwiftUIStateStore<State> : ObservableObject, StoreProtocol {
    
    private let _store: Store<State>
    
    internal init(_ store: Store<State>) {
        _store = store
    }
    
    public func getState() -> State {
        return _store.getState()
    }
    
    public func dispatch(_ action: Action) {
        _store.dispatch(action)
    }
    
    public func publisher<Value>(for keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        _store.map(keyPath).eraseToAnyPublisher()
    }
    
    public func publisher<Value>(for keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> where Value: Equatable {
        _store.map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}
