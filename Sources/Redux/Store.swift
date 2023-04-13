//
//  Store.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Foundation

public class Store<State> : StoreProtocol, Observable {
    
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
        
        isDispatching = true
        currentState = currentReducer(currentState, action)
        isDispatching = false
        
        sendValue(currentState)
    }
    
    // MARK: - Observable
    
    public typealias Output = State
    
    private let lock = Lock()
    
    private var downstreams = ConduitList<Output>.empty
    
    public func receive<Downstream>(
        observer: Downstream
    ) where Downstream : Observer, Output == Downstream.Input {
        lock.lock()
        let conduit = Conduit(parent: self, downstream: observer)
        downstreams.insert(conduit)
        lock.unlock()
        observer.receive(observation: conduit)
    }
    
    private func disassociate(_ conduit: ConduitBase<State>) {
        lock.lock()
        downstreams.remove(conduit)
        lock.unlock()
    }
    
    private func sendValue(_ newValue: Output) {
        lock.lock()
        let downstreams = self.downstreams
        lock.unlock()
        downstreams.forEach { conduit in
            conduit.offer(newValue)
        }
    }
}

extension Store {
    
    internal class Conduit<Downstream> : ConduitBase<Output> where Downstream : Observer, Downstream.Input == Output {
        
        private var parent: Store?
        
        private let downstream: Downstream
        
        private let lock = Lock()
        
        private let downstreamLock = Lock()
        
        private var deliveredCurrentValue = false
        
        init(parent: Store, downstream: Downstream) {
            self.parent = parent
            self.downstream = downstream
        }
                
        override func offer(_ output: Store<State>.Output) {
            lock.lock()
            deliveredCurrentValue = true
            lock.unlock()
            downstreamLock.lock()
            downstream.receive(output)
            downstreamLock.unlock()
        }
        
        override func request() {
            lock.lock()
            if deliveredCurrentValue {
                lock.unlock()
                return
            }
            
            deliveredCurrentValue = true
            guard let currentValue = parent?.currentState else {
                lock.unlock()
                return
            }

            lock.unlock()
            downstreamLock.lock()
            downstream.receive(currentValue)
            downstreamLock.unlock()
        }
        
        override func dispose() {
            lock.lock()
            let parent = self.parent
            self.parent = nil
            lock.unlock()
            
            parent?.disassociate(self)
        }
    }

}
