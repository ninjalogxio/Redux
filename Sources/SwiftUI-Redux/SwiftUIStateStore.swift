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
    
    private var state: PassthroughSubject<State, Never> = PassthroughSubject()
    
    private let _getState: () -> State
    
    private let _dispatch: Dispatch
    
    private var disposables: Set<AnyDisposable> = []
    
    internal init(_ store: Store<State>) {
        _getState = store.getState
        _dispatch = store.dispatch(_:)
        
        store.sink { [state] in
            state.send($0)
        }.store(in: &disposables)
    }
    
    public func getState() -> State {
        return _getState()
    }
    
    public func dispatch(_ action: Action) {
        _dispatch(action)
    }
    
    public func publisher<Value>(for keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        return state.map(keyPath).eraseToAnyPublisher()
    }
    //
    public func publisher<Value>(
        for keyPath: KeyPath<State, Value>,
        removeDuplicates: Bool = true
    ) -> AnyPublisher<Value, Never> where Value: Equatable {
        let publisher = state.map(keyPath)
        if removeDuplicates {
            return publisher.removeDuplicates().eraseToAnyPublisher()
        }
        return publisher.eraseToAnyPublisher()
    }
}
