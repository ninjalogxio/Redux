//
//  ObservationList.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Foundation

internal enum ObservationList<Value> {
    
    case empty
    case single(Observation<Value>)
    case many(Set<Observation<Value>>)
}

extension ObservationList {
    
    internal init() {
        self = .empty
    }
    
    internal mutating func insert(_ observation: Observation<Value>) {
        switch self {
        case .empty:
            self = .single(observation)
        case .single(observation):
            break
        case .single(let existingObservation):
            self = .many([existingObservation, observation])
        case .many(var set):
            set.insert(observation)
            self = .many(set)
        }
    }
    
    internal func forEach(_ body: (Observation<Value>) -> Void) {
        switch self {
        case .empty:
            break
        case .single(let observation):
            body(observation)
        case .many(let set):
            set.forEach(body)
        }
    }
    
    internal mutating func remove(_ observation: Observation<Value>) {
        switch self {
        case .single(observation):
            self = .empty
        case .empty, .single:
            break
        case .many(var set):
            set.remove(observation)
            self = .many(set)
        }
    }
}
