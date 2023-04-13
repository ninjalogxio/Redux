//
//  Observer.swift
//  
//
//  Created by Kinglets on 2023/3/18.
//

import Foundation

public protocol Observer {
    
    associatedtype Input
    
    func receive(observation: Observation)
    
    func receive(_ input: Input)
}

public struct AnyObserver<Input> : Observer {
    
    private let _receiveObservation: (Observation) -> Void
    private let _receiveValue: (Input) -> Void
    
    init(
        receiveObservation: @escaping (Observation) -> Void,
        receiveValue: @escaping (Input) -> Void
    ) {
        _receiveObservation = receiveObservation
        _receiveValue = receiveValue
    }
    
    public func receive(observation: Observation) {
        _receiveObservation(observation)
    }
    
    public func receive(_ input: Input) {
        _receiveValue(input)
    }
}

public enum Observers {
    
}
