//
//  SlidableModifier.swift
//  
//
//  Created by Enes Karaosman on 10.05.2020.
//

import SwiftUI

public struct SlidableModifier: ViewModifier, Animatable {
    
    public enum SlideAxis {
        case left2Right
        case right2Left
    }
    
    private var contentOffset: CGSize {
        return switch slideAxis {
        case .left2Right: .init(width: currentSlotsWidth, height: 0)
        case .right2Left: .init(width: -currentSlotsWidth, height: 0)
        }
    }
    
    private var slotOffset: CGSize {
        return switch slideAxis {
        case .left2Right: .init(width: currentSlotsWidth - totalSlotWidth, height: 0)
        case .right2Left: .init(width: totalSlotWidth - currentSlotsWidth, height: 0)
        }
    }
    
    private var zStackAlignment: Alignment {
        return switch slideAxis {
        case .left2Right: .leading
        case .right2Left: .trailing
        }
    }
    
    /// Animated slot widths of total
    @State
    private var currentSlotsWidth: CGFloat = 0
    
    /// To restrict the bounds of slots
    private func optWidth(value: CGFloat) -> CGFloat {
        min(abs(value), totalSlotWidth)
    }
    
    public var animatableData: Double {
        get { Double(self.currentSlotsWidth) }
        set { self.currentSlotsWidth = CGFloat(newValue) }
    }
    
    private var totalSlotWidth: CGFloat {
        slots.map(\.style.slotWidth).reduce(0, +)
    }
    
    private var slots: [Slot] {
        slideAxis == .left2Right ? leadingSlots : trailingSlots
    }
    
    @State private var slideAxis: SlideAxis = SlideAxis.left2Right
    private var leadingSlots: [Slot]
    private var trailingSlots: [Slot]
    
    public init(leading: [Slot], trailing: [Slot]) {
        self.leadingSlots = leading
        self.trailingSlots = trailing
    }
    
    private func flushState() {
        withAnimation {
            currentSlotsWidth = 0
        }
    }
    
    public func body(content: Content) -> some View {
        
        ZStack(alignment: zStackAlignment) {
            
            content
                .offset(contentOffset)

            if !currentSlotsWidth.isZero {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.001)
                    .onTapGesture(perform: flushState)
            }

            slotContainer
                .offset(slotOffset)
                .frame(width: totalSlotWidth)
            
        }
        .gesture(gesture)
        
    }
    
    // MARK: Slot Container
    private var slotContainer: some View {
        HStack(spacing: 0) {
            
            ForEach(self.slots) { slot in
                VStack(spacing: 4) {
                    Spacer() // To extend top edge

                    if slot.style.formatImage {
                        slot.image()
                            .resizable()
                            .scaledToFit()
                            .frame(width: slot.style.slotWidth * 0.4)
                            .foregroundColor(slot.style.imageColor)
                    } else {
                        slot.image()
                    }

                    slot.title()
                    
                    Spacer() // To extend bottom edge
                }
                .frame(width: slot.style.slotWidth)
                .background(slot.style.background)
                .onTapGesture {
                    slot.action()
                    flushState()
                }
            }
        }
    }
    
    // MARK: - Drag Gesture
    private var gesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let amount = value.translation.width
                
                if amount < 0 {
                    slideAxis = .right2Left
                } else {
                    slideAxis = .left2Right
                }
                
                currentSlotsWidth = optWidth(value: amount)
            }
            .onEnded { value in
                withAnimation {
                    if currentSlotsWidth < (totalSlotWidth / 2) {
                        currentSlotsWidth = 0
                    } else {
                        currentSlotsWidth = totalSlotWidth
                    }
                }
            }
    }
}
