//
//  Observable+MapKeyPath.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

import Foundation

extension Observable {
    
    public func map<T>(_ keyPath: KeyPath<Output, T>) -> Observables.MapKeyPath<Self, T> {
        return .init(upstream: self, keyPath: keyPath)
    }
    
    public func map<T0, T1>(
        _ keyPath0: KeyPath<Output, T0>,
        _ keyPath1: KeyPath<Output, T1>
    ) -> Observables.MapKeyPath2<Self, T0, T1> {
        return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1)
    }
    
    public func map<T0, T1, T2>(
        _ keyPath0: KeyPath<Output, T0>,
        _ keyPath1: KeyPath<Output, T1>,
        _ keyPath2: KeyPath<Output, T2>
    ) -> Observables.MapKeyPath3<Self, T0, T1, T2> {
        return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1, keyPath2: keyPath2)
    }
}

extension Observables {
    
    public struct MapKeyPath<Upstream, Output> : Observable where Upstream : Observable {
        
        public let upstream: Upstream
        
        public let keyPath: KeyPath<Upstream.Output, Output>
        
        public func receive<Downstream>(
            observer: Downstream
        ) where Downstream : Observer, Output == Downstream.Input {
            upstream.receive(observer: Inner(downstream: observer, parent: self))
        }
    }
    
    public struct MapKeyPath2<Upstream, Output0, Output1> : Observable where Upstream : Observable {
        
        public typealias Output = (Output0, Output1)
        
        public let upstream: Upstream
        
        public let keyPath0: KeyPath<Upstream.Output, Output0>
        
        public let keyPath1: KeyPath<Upstream.Output, Output1>
        
        public func receive<Downstream>(
            observer: Downstream
        ) where Downstream : Observer, Output == Downstream.Input {
            upstream.receive(observer: Inner(downstream: observer, parent: self))
        }
    }
    
    public struct MapKeyPath3<Upstream, Output0, Output1, Output2> : Observable where Upstream : Observable {
        
        public typealias Output = (Output0, Output1, Output2)
        
        public let upstream: Upstream
        
        public let keyPath0: KeyPath<Upstream.Output, Output0>
        
        public let keyPath1: KeyPath<Upstream.Output, Output1>
        
        public let keyPath2: KeyPath<Upstream.Output, Output2>
        
        public func receive<Downstream>(
            observer: Downstream
        ) where Downstream : Observer, Output == Downstream.Input {
            upstream.receive(observer: Inner(downstream: observer, parent: self))
        }
    }
    
}

extension Observables.MapKeyPath {
    
    private struct Inner<Downstream> : Observer where Downstream : Observer, Downstream.Input == Output {
        
        typealias Input = Upstream.Output
        
        private let downstream: Downstream
        
        private let keyPath: KeyPath<Input, Output>
        
        init(downstream: Downstream, parent: Observables.MapKeyPath<Upstream, Output>) {
            self.downstream = downstream
            self.keyPath = parent.keyPath
        }

        func receive(observation: Observation) {
            downstream.receive(observation: observation)
        }

        func receive(_ input: Upstream.Output) {
            let output = (
                input[keyPath: keyPath]
            )
            downstream.receive(output)
        }
    }
}

extension Observables.MapKeyPath2 {
    
    private struct Inner<Downstream> : Observer where Downstream : Observer, Downstream.Input == Output {
        
        typealias Input = Upstream.Output
        
        private let downstream: Downstream
        
        private let keyPath0: KeyPath<Input, Output0>
        
        private let keyPath1: KeyPath<Input, Output1>
        
        init(downstream: Downstream, parent: Observables.MapKeyPath2<Upstream, Output0, Output1>) {
            self.downstream = downstream
            self.keyPath0 = parent.keyPath0
            self.keyPath1 = parent.keyPath1
        }

        func receive(observation: Observation) {
            downstream.receive(observation: observation)
        }

        func receive(_ input: Upstream.Output) {
            let output = (
                input[keyPath: keyPath0],
                input[keyPath: keyPath1]
            )
            downstream.receive(output)
        }
    }
}

extension Observables.MapKeyPath3 {
    
    private struct Inner<Downstream> : Observer where Downstream : Observer, Downstream.Input == Output {
        
        typealias Input = Upstream.Output
        
        private let downstream: Downstream
        
        private let keyPath0: KeyPath<Input, Output0>
        
        private let keyPath1: KeyPath<Input, Output1>
        
        private let keyPath2: KeyPath<Input, Output2>
        
        init(downstream: Downstream, parent: Observables.MapKeyPath3<Upstream, Output0, Output1, Output2>) {
            self.downstream = downstream
            self.keyPath0 = parent.keyPath0
            self.keyPath1 = parent.keyPath1
            self.keyPath2 = parent.keyPath2
        }

        func receive(observation: Observation) {
            downstream.receive(observation: observation)
        }

        func receive(_ input: Upstream.Output) {
            let output = (
                input[keyPath: keyPath0],
                input[keyPath: keyPath1],
                input[keyPath: keyPath2]
            )
            downstream.receive(output)
        }
    }
}
