//
//  StoreProtocol.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Foundation

public protocol StoreProtocol {
    
    associatedtype State
    
    func getState() -> State
    
    func dispatch(_ action: Action) -> Void
    
    func addObserver<O>(_ observer: O) -> Disposable where O : Observer, O.Value == State
    
    func addObserver<O, S>(_ observer: O, transform: @escaping (Transform<State>) -> Transform<S>) -> Disposable where O : Observer, O.Value == S
}

