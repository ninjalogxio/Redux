//
//  Observable+Sink.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

extension Observable {
    
    public func sink(receiveValue: @escaping (Output) -> Void) -> AnyDisposable {
        let observer = Observers.Sink(receiveValue: receiveValue)
        receive(observer: observer)
        return AnyDisposable(observer)
    }
}

extension Observers {
    
    public final class Sink<Input> : Observer, Disposable {
        
        public var receiveValue: (Input) -> Void
        
        private var status = ObservationStatus.awaiting
        
        private let lock = Lock()
        
        public init(receiveValue: @escaping (Input) -> Void) {
            self.receiveValue = receiveValue
        }
        
        public func receive(observation: Observation) {
            lock.lock()
            guard case .awaiting = status else {
                lock.unlock()
                observation.dispose()
                return
            }
            
            status = .observed(observation)
            lock.unlock()
            observation.request()
        }
        
        public func receive(_ input: Input) {
            lock.lock()
            let receiveValue = self.receiveValue
            lock.unlock()
            receiveValue(input)
        }
        
        public func dispose() {
            lock.lock()
            guard case .observed(let observation) = status else {
                lock.unlock()
                return
            }
            
            status = .completed
            
            withExtendedLifetime(receiveValue) {
                receiveValue = { _ in }
                lock.unlock()
            }
            observation.dispose()
        }
    }
    
}
