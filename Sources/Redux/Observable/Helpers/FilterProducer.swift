//
//  FilterProducer.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

internal class FilterProducer<
    Downstream,
    Input,
    Output,
    Filter
> where Downstream : Observer, Downstream.Input == Output {
    
    internal final let downstream: Downstream
    
    internal final let filter: Filter
    
    private let lock = Lock()
    
    private var state = ObservationStatus.awaiting
    
    internal init(downstream: Downstream, filter: Filter) {
        self.downstream = downstream
        self.filter = filter
    }
    
    internal func receive(newValue: Input) -> PartialCompletion<Output?> {
        abstractMethod()
    }
}

extension FilterProducer : Observer {
    
    internal func receive(observation: Observation) {
        lock.lock()
        guard case .awaiting = state else {
            lock.unlock()
            observation.dispose()
            return
        }
        
        state = .observed(observation)
        lock.unlock()
        downstream.receive(observation: self)
    }
    
    func receive(_ input: Input) {
        lock.lock()
        switch state {
        case .awaiting:
            lock.unlock()
            fatalError("Invalid state: Received value before receiving observation")
        case .completed:
            lock.unlock()
        case .observed(let observation):
            lock.unlock()
            switch receive(newValue: input) {
            case .continue(let output?):
                downstream.receive(output)
            case .continue(nil):
                break // ignore
            case .finished:
                lock.lock()
                state = .completed
                lock.unlock()
                observation.dispose()
            }
        }
    }
}

extension FilterProducer : Observation {
    
    internal func request() {
        lock.lock()
        switch state {
        case .awaiting:
            lock.unlock()
            fatalError("Invalid state: Received request before sending observation")
        case .completed:
            lock.unlock()
            return
        case .observed(let observation):
            lock.unlock()
            observation.request()
        }
    }
    
    internal func dispose() {
        lock.lock()
        guard case .observed(let observation) = state else {
            state = .completed
            lock.unlock()
            return
        }
        
        state = .completed
        lock.unlock()
        observation.dispose()
    }
}
