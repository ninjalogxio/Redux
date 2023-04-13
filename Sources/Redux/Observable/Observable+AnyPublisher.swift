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
            upstream.receive(observer: Inner(downstream: subscriber))
        }
    }
}

extension Observables.Publisher {
    
    private final class Inner<Downstream> : Observer, Subscription where Downstream : Subscriber, Downstream.Input == Output {
        
        typealias Input = Downstream.Input
        
        private let downstream: Downstream
        
        private let lock = Lock()
        
        private var state = ObservationStatus.awaiting
        
        private var observation: Observation?
        
        init(downstream: Downstream) {
            self.downstream = downstream
        }
        
        func receive(observation: Observation) {
            lock.lock()
            guard case .awaiting = state else {
                lock.unlock()
                observation.dispose()
                return
            }
            
            state = .observed(observation)
            lock.unlock()
            downstream.receive(subscription: self)
        }
        
        func receive(_ input: Input) {
            lock.lock()
            switch state {
            case .awaiting:
                lock.unlock()
                fatalError("Invalid state: Received value before receiving observation")
            case .completed:
                lock.unlock()
            case .observed:
                lock.unlock()
                _ = downstream.receive(input)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
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
        
        func cancel() {
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
}
#endif
