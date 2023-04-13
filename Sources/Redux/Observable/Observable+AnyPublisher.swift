//
//  Observable+AnyPublisher.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

#if canImport(Combine)
import Combine

extension Observable {
    
    public func eraseToAnyPublisher() -> AnyPublisher<Output, Never> {
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
    
    private final class Inner<Downstream> : Observer, Subscription where Downstream : Subscriber, Downstream.Input == Output {
        
        typealias Input = Downstream.Input
        
        private let downstream: Downstream
        
        private let lock = Lock()
        
        private var finished = false
        
        private var observation: Observation?
        
        init(downstream: Downstream) {
            self.downstream = downstream
        }
        
        func receive(observation: Observation) {
            lock.lock()
            if finished || self.observation != nil {
                lock.unlock()
                observation.dispose()
                return
            }
            self.observation = observation
            lock.unlock()
            downstream.receive(subscription: self)
        }
        
        func receive(_ input: Input) {
            lock.lock()
            if finished {
                lock.unlock()
                return
            }
            
            lock.unlock()
            _ = downstream.receive(input)
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            let observation = self.observation
            lock.unlock()
            observation?.request()
        }
        
        func cancel() {
            lock.lock()
            guard !finished, let observation = observation else {
                lock.unlock()
                return
            }
            self.observation = nil
            finished = true
            lock.unlock()
            observation.dispose()
        }
    }
}
#endif
