//
//  Extensions.swift
//  
//
//  Created by Enes Karaosman on 9.05.2020.
//

import SwiftUI

public extension View {
    
    func swipeLeft2Right(slots: [Slot]) -> some View {
        return self.modifier(SlidableModifier(slots: slots, slideAxis: .left2Right))
    }
    
    func swipeRight2Left(slots: [Slot]) -> some View {
        return self.modifier(SlidableModifier(slots: slots, slideAxis: .right2Left))
    }
    
    func embedInAnyView() -> AnyView {
        return AnyView ( self )
    }
}
