//
//  File.swift
//  
//
//  Created by Enes Karaosman on 10.05.2020.
//

import SwiftUI

public struct SlidableModifier: ViewModifier {
    
    public enum SlideAxis {
        case left2Right
        case right2Left
    }
    
    private var contentOffset: CGSize {
        switch self.slideAxis {
        case .left2Right:
            return .init(width: self.currentSlotsWidth, height: 0)
        case .right2Left:
            return .init(width: -self.currentSlotsWidth, height: 0)
        }
    }
    
    private var slotOffset: CGSize {
        switch self.slideAxis {
        case .left2Right:
            return .init(width: self.currentSlotsWidth - self.totalSlotWidth, height: 0)
        case .right2Left:
            return .init(width: self.totalSlotWidth - self.currentSlotsWidth, height: 0)
        }
    }
    
    private var zStackAlignment: Alignment {
        switch self.slideAxis {
        case .left2Right:
            return .leading
        case .right2Left:
            return .trailing
        }
    }
    
    /// Animated slot widths of total
    @State var currentSlotsWidth: CGFloat = 0
    
    /// To restrict the bounds of slots
    private func optWidth(value: CGFloat) -> CGFloat {
        return min(abs(value), totalSlotWidth)
    }
    
    var animatableData: Double {
        get { Double(self.currentSlotsWidth) }
        set { self.currentSlotsWidth = CGFloat(newValue) }
    }
    
    private var totalSlotWidth: CGFloat {
        return slots.map { $0.style.slotWidth }.reduce(0, +)
    }
    
    private var slots: [Slot]
    private var slideAxis: SlideAxis
    
    public init(slots: [Slot], slideAxis: SlideAxis) {
        self.slots = slots
        self.slideAxis = slideAxis
    }
    
    private func flushState() {
        withAnimation {
            self.currentSlotsWidth = 0
        }
    }
    
    public func body(content: Content) -> some View {
        
        ZStack(alignment: self.zStackAlignment) {
            
            content
                .offset(self.contentOffset)
                .onTapGesture(perform: flushState)
            
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
            .offset(self.slotOffset)
            .frame(width: self.totalSlotWidth)
            
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let amount = value.translation.width
                    
                    if self.slideAxis == .left2Right {
                        if amount < 0 { return }
                    } else {
                        if amount > 0 { return }
                    }
                    
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
