//
//  Connect.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Combine
import Redux
import SwiftUI

private struct DispatchEnvironmentKey : EnvironmentKey {
    
    public static let defaultValue: Dispatch = { _ in
        fatalError("Please use 'Connect<State, Content>' to inject dispatch function")
    }
}

extension EnvironmentValues {
    
    public var dispatch: Dispatch {
        get { self[DispatchEnvironmentKey.self] }
        set { self[DispatchEnvironmentKey.self] = newValue }
    }
}

public struct Connect<State, Content> : View where Content : View {
    
    @EnvironmentObject private var store: SwiftUIStateStore<State>
        
    public let content: (SwiftUIStateStore<State>) -> Content
    
    public init(@ViewBuilder content: @escaping (SwiftUIStateStore<State>) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(store)
            .environment(\.dispatch, store.dispatch)
    }
}
