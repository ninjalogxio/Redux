//
//  Observable+Map.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

extension Observable {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.Map<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Observables {
    
    public struct Map<Upstream, Output> : Observable where Upstream : Observable {
        
        public let upstream: Upstream
        
        public let transform: (Upstream.Output) -> Output
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func observe<Downstream>(
            _ observer: Downstream
        ) where Downstream : Observer, Output == Downstream.Input {
            upstream.observe(Inner(downstream: observer, map: transform))
        }
    }
}

extension Observables.Map {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.Map<Upstream, T> {
        return .init(upstream: upstream) {
            transform(self.transform($0))
        }
    }
}

extension Observables.Map {
    
    private struct Inner<Downstream> : Observer where Downstream : Observer, Downstream.Input == Output {
        
        typealias Input = Upstream.Output
        
        private let downstream: Downstream
        
        private let map: (Input) -> Output
        
        init(downstream: Downstream, map: @escaping (Input) -> Output) {
            self.downstream = downstream
            self.map = map
        }

        func receive(observation: Observation) {
            downstream.receive(observation: observation)
        }

        func receive(_ input: Upstream.Output) {
            downstream.receive(map(input))
        }
    }
}
