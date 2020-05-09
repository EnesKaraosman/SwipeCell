//
//  Extensions.swift
//  
//
//  Created by Enes Karaosman on 9.05.2020.
//

import SwiftUI

public extension View {
    
    func swipeFromLeading(slots: [Slot]) -> some View {
        return self.modifier(LeftToRightSlidableModifier(slots: slots))
    }
    
    func embedInAnyView() -> AnyView {
        return AnyView ( self )
    }
}
