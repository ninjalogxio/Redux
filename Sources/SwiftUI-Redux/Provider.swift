//
//  Provider.swift
//  
//
//  Created by Kinglets on 2023/3/17.
//

import Redux
import SwiftUI

public struct Provider<StoreType, Content> : View where StoreType : StoreProtocol, Content : View {
    
    private let store: _Store<StoreType.State>
    
    private let content: () -> Content
    
    public init(store: StoreType, @ViewBuilder content: @escaping () -> Content) {
        self.store = _Store(store)
        self.content = content
    }
    
    public var body: some View {
        content()
            .environmentObject(store)
    }
}
