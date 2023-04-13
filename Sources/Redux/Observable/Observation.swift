//
//  Observation.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Foundation

public protocol Observation : Disposable {
    
    func request()
}
