//
//  ConduitBase.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

import Foundation

internal class ConduitBase<Output> : Observation {

    internal init() {}

    internal func offer(_ output: Output) {
        abstractMethod()
    }
    
    internal func request() {
        abstractMethod()
    }
    
    internal func dispose() {
        abstractMethod()
    }
}

extension ConduitBase: Equatable {
    
    internal static func == (lhs: ConduitBase<Output>, rhs: ConduitBase<Output>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension ConduitBase: Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
