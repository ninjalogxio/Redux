//
//  Disposable.swift
//  
//
//  Created by Kinglets on 2023/3/19.
//

import Foundation

public protocol Disposable {
    
    func dispose()
}

extension Disposable {
    
    public func store<C>(in collection: inout C) where C : RangeReplaceableCollection, C.Element == AnyDisposable {
        AnyDisposable(self).store(in: &collection)
    }
    
    public func store(in set: inout Set<AnyDisposable>) {
        AnyDisposable(self).store(in: &set)
    }
}

public class AnyDisposable : Disposable, Hashable {
    
    private var _dispose: (() -> Void)?
    
    public init(_ dispose: @escaping () -> Void) {
        _dispose = dispose
    }
    
    public init<D>(_ disposable: D) where D : Disposable {
        _dispose = disposable.dispose
    }
    
    public func dispose() {
        _dispose?()
        _dispose = nil
    }
    
    public static func == (lhs: AnyDisposable, rhs: AnyDisposable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    deinit {
        _dispose?()
    }
}

extension AnyDisposable {
    
    public func store<C>(in collection: inout C) where C : RangeReplaceableCollection, C.Element == AnyDisposable {
        collection.append(self)
    }
    
    public func store(in set: inout Set<AnyDisposable>) {
        set.insert(self)
    }
}
