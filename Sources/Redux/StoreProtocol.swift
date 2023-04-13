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
    
}
