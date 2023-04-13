//
//  Violations.swift
//  
//
//  Created by Kinglets on 2023/4/13.
//

internal func abstractMethod(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Abstract method call", file: file, line: line)
}
