//
//  Observable.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

public protocol Observable {
    
    associatedtype Output
    
    func receive<O>(observer: O) where O : Observer, O.Input == Output
}

extension Observable {
    
    @inlinable
    public func eraseToAnyObservable() -> AnyObservable<Output> {
        return .init(self)
    }
}

public struct AnyObservable<Output> {
    
    @usableFromInline
    internal let box: ObservableBoxBase<Output>
    
    public init<ObservableType>(
        _ observable: ObservableType
    ) where ObservableType : Observable, ObservableType.Output == Output {
        if let erased = observable as? AnyObservable<Output> {
            box = erased.box
        } else {
            box = ObservableBox(base: observable)
        }
    }
}

extension AnyObservable : Observable {
    
    public func receive<O>(observer: O) where O : Observer, Output == O.Input {
        box.receive(observer: observer)
    }
}

@usableFromInline
internal class ObservableBoxBase<Output> : Observable {
    
    @inlinable
    internal init() {}

    @usableFromInline
    internal func receive<O>(observer: O) where O : Observer, Output == O.Input {
        abstractMethod()
    }
}

@usableFromInline
internal final class ObservableBox<ObservableType> : ObservableBoxBase<ObservableType.Output> where ObservableType : Observable {
    
    @usableFromInline
    internal typealias Output = ObservableType.Output
    
    @usableFromInline
    internal let base: ObservableType

    @inlinable
    internal init(base: ObservableType) {
        self.base = base
    }
    
    @inlinable
    override func receive<O>(observer: O) where O : Observer, ObservableType.Output == O.Input {
        base.receive(observer: observer)
    }
}

