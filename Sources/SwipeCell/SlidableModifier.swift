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
//            let width = isDestructiveModeActive ? self.destructiveSlotOffset : (self.totalSlotWidth - self.currentSlotsWidth)
            let width = isDestructiveModeActive ? self.destructiveSlotOffset : (self.destructiveSlotFixedWidth - self.currentSlotsWidth)
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
    
    @State var _destructiveSlotOffset: CGFloat = 0
    private var destructiveSlotOffset: CGFloat {
        let width = self.destructiveSlot?.style.slotWidth ?? 0
        let offsetAmount = (self.slideAxis == SlideAxis.right2Left ? -1 : 1) * _destructiveSlotOffset
        return offsetAmount + width
    }
    
    private let destructiveSlotFixedWidth = UIScreen.main.bounds.width * 0.8
    
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
                self.currentSlotsWidth = 0
            }
        }
    }
    
    // MARK: - Body
    public func body(content: Content) -> some View {
        
        ZStack(alignment: self.zStackAlignment) {
            
            content
                .offset(self.contentOffset)
                .onTapGesture(perform: flushState)
            
            slotContainer
            .frame(width: self.destructiveSlotFixedWidth)
            .offset(self.slotOffset)
//                .offset(x: 200, y: 0) // Initial destructiveSlotFixedWidth, then decrease
            .animation(.easeOut)
            
        }
        .gesture(self.dragGesture)
        
    }
    
    // MARK: - Single Slot View
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
        .onTapGesture {
            slot.action()
            self.flushState()
        }
    }
    
    // MARK: - Slot Container View
    private var slotContainer: some View {
        Group {
            
            if !isDestructiveModeActive {
                HStack(spacing: 0) {
                    ForEach(self.slots, content: self.slotView)
                    Spacer() // TODO: Change order due to axis
                }
                .frame(width: self.destructiveSlotFixedWidth)
            }
            
            if isDestructiveModeActive {
                Rectangle()
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Gesture
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
                    self._destructiveSlotOffset = amount
                    // Check is destructive sliding active
                    // And control
                    let threshold = self.totalSlotWidth// UIScreen.main.bounds.width / 2
                    if abs(value.translation.width) > threshold {
                        print("Destructive mode (onChanged): active")
                        self._isDestructiveModeActive = true
                    } else {
                        print("Destructive mode (onChanged): passive")
                        self._isDestructiveModeActive = false
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
                    print("Destructive mode (onEnded): active")
                } else {
                    self._isDestructiveModeActive = false
                    print("Destructive mode (onEnded): passive")
                }
            }
            
            
        }
    }
    
}
