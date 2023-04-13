//
//  Provider.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Redux
import SwiftUI

public struct Provider<State, Content> : View where Content : View {
    
    private let store: SwiftUIStateStore<State>
    
    private let content: () -> Content
    
    public init(store: Store<State>, @ViewBuilder content: @escaping () -> Content) {
        self.store = SwiftUIStateStore(store)
        self.content = content
    }
    
    public var body: some View {
        content()
            .environmentObject(store)
    }
}
