//
//  Observable+RemoveDuplicates.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

extension Observable where Output : Equatable {

    public func removeDuplicates() -> Observables.RemoveDuplicates<Self> {
        return removeDuplicates(by: ==)
    }
}

extension Observable {

    public func removeDuplicates(by predicate: @escaping (Output, Output) -> Bool) -> Observables.RemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Observables {
    
    public struct RemoveDuplicates<Upstream> : Observable where Upstream : Observable {
        
        public typealias Output = Upstream.Output
        
        public let upstream: Upstream
        
        public let predicate: (Output, Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Output, Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func observe<Downstream>(
            _ observer: Downstream
        ) where Downstream : Observer, Upstream.Output == Downstream.Input {
            upstream.observe(Inner(downstream: observer, filter: predicate))
        }
    }
}

extension Observables.RemoveDuplicates {
    
    private final class Inner<Downstream> : FilterProducer<Downstream, Upstream.Output, Upstream.Output, (Output, Output) -> Bool> where Downstream : Observer, Downstream.Input == Upstream.Output {
        
        private var last: Upstream.Output?
        
        override func receive(newValue: Upstream.Output) -> PartialCompletion<Upstream.Output?> {
            
            let last = self.last
            self.last = newValue
            
            return last.map {
                filter($0, newValue)
                ? .continue(nil)
                : .continue(newValue)
            } ?? .continue(newValue)
        }
    }
}
