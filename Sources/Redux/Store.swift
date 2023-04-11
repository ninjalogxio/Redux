//
//  Store.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Foundation

public class Store<State> : StoreProtocol {
    
    private let currentReducer: AnyReducer<State>
    
    private var currentState: State!
    
    @Synchronized private var isDispatching = false
    
    private lazy var dispatchFunction: Dispatch! = _defaultDispatch(_:)
    
    public init<R>(
        reducer: R,
        preloadedState: State?,
        enhancer: StoreEnhancer<State>? = nil
    ) where R : Reducer, R.State == State {
        currentReducer = AnyReducer(reducer.handle)
        if let enhancer = enhancer {
            dispatchFunction = enhancer(getState, dispatchFunction)
        }
        
        if let state = preloadedState {
            currentState = state
        } else {
            dispatch(ReduxInitAction())
        }
    }
        
    public func getState() -> State {
        guard !isDispatching else {
            fatalError("You may not call store.getState() while the reducer is executing. "
                       + "The reducer has already received the state as an argument. "
                       + "Pass it down from the top reducer instead of reading it from the store.")
        }
        return currentState
    }
    
    public func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
    
    private func _defaultDispatch(_ action: Action) {
        guard !isDispatching else {
            fatalError("Reducers may not dispatch actions.")
        }
        
        let oldValue = currentState
        isDispatching = true
        currentState = currentReducer(currentState, action)
        isDispatching = false
        
        observationList.forEach {
            $0.receive(oldValue: oldValue, newValue: currentState)
        }
    }
    
    private var observationList = ObservationList<State>()
    
    public func addObserver<O>(_ observer: O) -> Disposable where O : Observer, O.Value == State {
        return addObserver(observer) { $0 }
    }
    
    public func addObserver<O, S>(_ observer: O, transform: @escaping (Transform<State>) -> Transform<S>) -> Disposable where O : Observer, O.Value == S {
        let first = Transform<State>()
        transform(first).update {
            observer.receive($1)
        }
        let observation = Observation(parent: self, transform: first)
        observationList.insert(observation)
        return observation
    }
    
    public func addObserver<O, S>(_ observer: O, transform: @escaping (Transform<State>) -> Transform<S>) -> Disposable where O : Observer, S : Equatable, O.Value == S {
        let first = Transform<State>()
        transform(first).removeDuplicates().update {
            observer.receive($1)
        }
        let observation = Observation(parent: self, transform: first)
        observationList.insert(observation)
        return observation
    }
    
    internal func disassociate(_ observation: Observation<State>) {
        observationList.remove(observation)
    }
}

