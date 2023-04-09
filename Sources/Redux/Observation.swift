//
//  Observation.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Foundation

internal class Observation<State> : Disposable, Hashable {
    
    private let parent: Store<State>
    private let transform: Transform<State>
    
    internal init(parent: Store<State>, transform: Transform<State>) {
        self.parent = parent
        self.transform = transform
    }
    
    internal func receive(oldValue: State?, newValue: State) {
        transform.receive(oldState: oldValue, newState: newValue)
    }
    
    internal func dispose() {
        parent.disassociate(self)
    }
    
    internal static func == (lhs: Observation<State>, rhs: Observation<State>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
