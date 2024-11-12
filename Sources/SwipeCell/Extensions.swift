//
//  Extensions.swift
//  
//
//  Created by Enes Karaosman on 9.05.2020.
//

import SwiftUI

public extension View {
    
    func onSwipe(leading: [Slot] = [], trailing: [Slot] = []) -> some View {
        modifier(SlidableModifier(leading: leading, trailing: trailing))
    }
    
    func embedInAnyView() -> AnyView {
        AnyView ( self )
    }
}
