//
//  Connect.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

internal struct Connect<State, Content> : View where Content : View {
    
    @EnvironmentObject private var store: _Store<State>
        
    internal let content: (State, @escaping Dispatch) -> Content
    
    public var body: some View {
        content(store.state, store.dispatch(_:))
    }
}

public protocol ConnectedView : View {
    
    associatedtype State
    associatedtype Props
    associatedtype V : View
    
    static func map(state: State, dispatch: @escaping Dispatch) -> Props
    
    func body(props: Props) -> V
}

extension ConnectedView {
    
    public var body: some View {
        Connect { state, dispatch in
            body(props: Self.map(state: state, dispatch: dispatch))
        }
    }
}
