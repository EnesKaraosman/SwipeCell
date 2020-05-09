//
//  Slot.swift
//  
//
//  Created by Enes Karaosman on 9.05.2020.
//

import SwiftUI

public struct Slot: Identifiable {
    /// Id
    public let id = UUID()
    /// The Icon will be displayed.
    public let image: () -> Image
    /// To allow modification on Text, wrap it with AnyView.
    public let title: () -> AnyView
    /// Tap Action
    public let action: () -> Void
    /// Style
    public let style: SlotStyle
}

public struct SlotStyle {
    /// Background color of slot.
    public let background: Color
    /// Image tint color
    public var imageColor: Color = .white
    /// Individual slot width
    var slotWidth: CGFloat = 60
}
