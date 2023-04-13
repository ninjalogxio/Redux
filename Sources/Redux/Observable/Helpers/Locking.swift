//
//  Locking.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

import Foundation

protocol Locking {
    
    func lock()
    
    func unlock()
}

extension DispatchSemaphore : Locking {
    
    convenience init() {
        self.init(value: 1)
    }
    
    func lock() {
        self.wait()
    }
    
    func unlock() {
        self.signal()
    }
}

typealias Lock = DispatchSemaphore
