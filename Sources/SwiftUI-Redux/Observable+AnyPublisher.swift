//
//  Observable+AnyPublisher.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

import Combine
import Foundation
import Redux

internal extension Observable {
    
    func eraseToAnyPublisher() -> AnyPublisher<Output, Never> {
        return Observables.Publisher(upstream: self)
            .eraseToAnyPublisher()
    }
}

extension Observables {
    
    internal class Publisher<Upstream> : Combine.Publisher where Upstream : Observable {
        
        internal typealias Output = Upstream.Output
        
        typealias Failure = Never
        
        internal let upstream: Upstream
        
        internal init(upstream: Upstream) {
            self.upstream = upstream
        }
                
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
            let outer = Inner(downstream: subscriber)
            subscriber.receive(subscription: outer)
            upstream.receive(observer: outer)
        }
    }
}

extension Observables.Publisher {
    
    final class Inner<Downstream> : Observer, Subscription where Downstream : Subscriber, Downstream.Input == Output {
        
        typealias Input = Downstream.Input
        
        private let downstream: Downstream
        
        private let semaphore = DispatchSemaphore(value: 1)
        
        private var finished = false
        
        private var observation: Observation?
        
        init(downstream: Downstream) {
            self.downstream = downstream
        }
        
        func receive(observation: Observation) {
            semaphore.wait()
            if finished || self.observation != nil {
                semaphore.signal()
                observation.dispose()
                return
            }
            self.observation = observation
            semaphore.signal()
            downstream.receive(subscription: self)
        }
        
        func receive(_ input: Input) {
            semaphore.wait()
            if finished {
                semaphore.signal()
                return
            }
            
            semaphore.signal()
            _ = downstream.receive(input)
        }
        
        func request(_ demand: Subscribers.Demand) {
            semaphore.wait()
            let observation = self.observation
            semaphore.signal()
            observation?.request()
        }
        
        func cancel() {
            semaphore.wait()
            guard !finished, let observation = observation else {
                semaphore.signal()
                return
            }
            self.observation = nil
            finished = true
            semaphore.signal()
            observation.dispose()
        }
    }
}
