//
//  SlidableModifier.swift
//  
//
//  Created by Enes Karaosman on 10.05.2020.
//

import SwiftUI

public struct SlidableModifier: AnimatableModifier {
    
    public enum SlideAxis {
        case left2Right
        case right2Left
    }
    
    private var destructiveSlot: Slot? {
        self.slots.first { $0.isDestructive }
    }
    
    private var destructiveSlotExist: Bool {
        destructiveSlot != nil
    }
    
    @State private var _isDestructiveModeActive = false
    
    private var isDestructiveModeActive: Bool {
        _isDestructiveModeActive && destructiveSlotExist
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
            let width = isDestructiveModeActive ? self.destructiveSlotOffset : (self.totalSlotWidth - self.currentSlotsWidth)
            return .init(width: width, height: 0)
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
    
    @State var destructiveSlotOffset: CGFloat = 0
    @State var destructiveSlotWidth: CGFloat = 0
    
    /// To restrict the bounds of slots
    private func optWidth(value: CGFloat) -> CGFloat {
        return min(abs(value), totalSlotWidth)
    }
    
    public var animatableData: Double {
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
    
    private func completeDestructiveSlotAction() {
        self.destructiveSlot?.action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                self.destructiveSlotWidth = 0
                self.currentSlotsWidth = 0
            }
        }
    }
    
    public func body(content: Content) -> some View {
        
        ZStack(alignment: self.zStackAlignment) {
            
            content
                .offset(self.contentOffset)
                .onTapGesture(perform: flushState)
            
            Rectangle()
            .foregroundColor(.clear)
            .overlay(slotContainer)
            .offset(self.slotOffset)
            .frame(width: self.totalSlotWidth)
            
        }
        .gesture(self.dragGesture)
        
    }
    
    private func slotView(slot: Slot) -> some View {
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
//        .modifier(
//            DestructiveModifier(
//                slot: slot,
//                width: self.destructiveSlotWidth
//            )
//        )
        .onTapGesture {
            slot.action()
            self.flushState()
        }
    }
    
    private var slotContainer: some View {
        ZStack(alignment: .trailing) {
            
            if !isDestructiveModeActive {
                HStack(spacing: 0) {
                    ForEach(self.slots, content: self.slotView)
                }
                .animation(.easeIn)
            }
            
            if isDestructiveModeActive {
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: min(self.destructiveSlotWidth, UIScreen.main.bounds.width * 0.8))
                    .offset(x: self.totalSlotWidth)
                    .animation(.easeOut)
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let amount = value.translation.width
                print(amount)
                if self.slideAxis == .left2Right {
                    if amount < 0 { return }
                } else {
                    if amount > 0 { return }
                }
                
                withAnimation {
                    self.destructiveSlotOffset = amount
                    // Check is destructive sliding active
                    // And control
                    let threshold = self.totalSlotWidth// UIScreen.main.bounds.width / 2
                    if abs(value.translation.width) > threshold {
                        print("Destructive mode (onChanged): active")
                        self._isDestructiveModeActive = true
                        self.destructiveSlotWidth = abs(amount)
                    } else {
                        print("Destructive mode (onChanged): passive")
                        self._isDestructiveModeActive = false
                        self.destructiveSlotWidth = 0
                    }
                    
                    self.currentSlotsWidth = self.optWidth(value: amount)
                    
                }
        }
        .onEnded { value in
            withAnimation {
                if self.currentSlotsWidth < (self.totalSlotWidth / 2) {
                    self.currentSlotsWidth = 0
                } else {
                    self.currentSlotsWidth = self.totalSlotWidth
                }
    
                let threshold = self.totalSlotWidth// UIScreen.main.bounds.width / 2
                if abs(value.translation.width) > threshold {
                    self._isDestructiveModeActive = true
                    self.destructiveSlotWidth = abs(value.translation.width)
                    print("Destructive mode (onEnded): active")
                } else {
                    self._isDestructiveModeActive = false
                    self.destructiveSlotWidth = 0
                    print("Destructive mode (onEnded): passive")
                }
            }
            
            
        }
    }
    
}

internal struct DestructiveModifier: ViewModifier {
    
    let slot: Slot
    let width: CGFloat
    @State private var flag = false
    
    private var frameWidth: CGFloat {
        width
    }
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content
            if flag {
            Spacer()
                .frame(width: frameWidth)
            }
        }
        .background(slot.style.background.opacity(0.2))
        .offset(x: frameWidth, y: 0)
        .onAppear {
            withAnimation {
                flag.toggle()
            }
        }
    }
}
