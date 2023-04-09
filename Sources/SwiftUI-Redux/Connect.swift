//
//  Connect.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

private struct DispatchKey : EnvironmentKey {
    
    static let defaultValue: Dispatch = { _ in
        // Nothing happens
    }
}

extension EnvironmentValues {
    
    public var dispatch: Dispatch {
        get { self[DispatchKey.self] }
        set { self[DispatchKey.self] = newValue }
    }
}


public struct Connect<State, Props, Content> : View where Props : ObservableObject, Content : View {
    
    @EnvironmentObject private var store: _Store<State>
    
    private let map: (State, @escaping Dispatch) -> Props
    
    private let content: () -> Content
    
    public init(map: @escaping (State, @escaping Dispatch) -> Props, @ViewBuilder content: @escaping () -> Content) {
        self.map = map
        self.content = content
    }
    
    public var body: some View {
        let props = map(store.state, store.dispatch)
        content()
            .environmentObject(props)
            .environment(\.dispatch, store.dispatch)
    }
}
