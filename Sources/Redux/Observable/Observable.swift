//
//  Observable.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

public protocol Observable {
    
    associatedtype Output
    
    func observe<O>(_ observer: O) where O : Observer, O.Input == Output
}
