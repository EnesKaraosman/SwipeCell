//
//  LeftToRightSlidableModifier.swift
//
//
//  Created by Enes Karaosman on 9.05.2020.
//

import SwiftUI

public struct LeftToRightSlidableModifier: ViewModifier {
    
    /// Animated slot widths of total
    @State private var currentSlotsWidth: CGFloat = 0
    
    /// To restrict the bounds of slots
    private func optWidth(value: CGFloat) -> CGFloat {
        return min(value, totalSlotWidth)
    }
    
    var animatableData: Double {
        get { Double(self.currentSlotsWidth) }
        set { self.currentSlotsWidth = CGFloat(newValue) }
    }
    
    private var totalSlotWidth: CGFloat {
        return slots.map { $0.style.slotWidth }.reduce(0, +)
    }
    
    private var slots: [Slot]
    
    public init(slots: [Slot]) {
        self.slots = slots
    }
    
    private flushState() {
        withAnimation {
            self.currentSlotsWidth = 0
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            
            Rectangle()
                .overlay(
                    HStack(spacing: 0) {
                        
                        ForEach(self.slots) { slot in
                            VStack(spacing: 4) {
                                Spacer() // To extend top edge
                                
                                slot.image()
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(slot.style.imageColor)
                                    .frame(width: slot.style.slotWidth * 0.4)
        
                                slot.title()
                                
                                Spacer() // To extend bottom edge
                            }
                            .frame(width: slot.style.slotWidth)
                            .background(slot.style.background)
                            .onTapGesture {
                                slot.action()
                                self.flushState()
                            }
                        }
                    }
            )
            .offset(x: -self.totalSlotWidth + self.currentSlotsWidth, y: 0)
            .frame(width: self.currentSlotsWidth)
            
            content
                .offset(x: self.currentSlotsWidth, y: 0)
                .onTapGesture(perform: flushState)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let amount = value.translation.width
                    if amount < 0 { return }
                    
                    self.currentSlotsWidth = self.optWidth(value: amount)
            }
            .onEnded { value in
                withAnimation {
                    if self.currentSlotsWidth < (self.totalSlotWidth / 2) {
                        self.currentSlotsWidth = 0
                    } else {
                        self.currentSlotsWidth = self.totalSlotWidth
                    }
                }
            }
        )
        
    }
    
}
