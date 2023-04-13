//
//  ConduitList.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

import Foundation

internal enum ConduitList<Output> {
    
    case empty
    case single(ConduitBase<Output>)
    case many(Set<ConduitBase<Output>>)
}

extension ConduitList {
    
    internal mutating func insert(_ conduit: ConduitBase<Output>) {
        switch self {
        case .empty:
            self = .single(conduit)
        case .single(conduit):
            break // This element already exists.
        case .single(let existingConduit):
            self = .many([existingConduit, conduit])
        case .many(var set):
            set.insert(conduit)
            self = .many(set)
        }
    }

    internal func forEach(_ body: (ConduitBase<Output>) throws -> Void) rethrows {
        switch self {
        case .empty:
            break
        case .single(let conduit):
            try body(conduit)
        case .many(let set):
            try set.forEach(body)
        }
    }

    internal mutating func remove(_ conduit: ConduitBase<Output>) {
        switch self {
        case .single(conduit):
            self = .empty
        case .empty, .single:
            break
        case .many(var set):
            set.remove(conduit)
            self = .many(set)
        }
    }
}

