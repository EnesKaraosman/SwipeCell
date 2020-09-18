# SwipeCell

### Preview
![](https://github.com/EnesKaraosman/SwipeCell/blob/master/Sources/SwipeCell/Resources/swipe_cell_both.png)

### Features

- [x] Swipe cell from Left to Right.
- [x] Swipe cell from Right to Left.
- [x] Swipe to both direction for same row.
- [ ] Destructive swipe

### Usage

* Simply add `onSwipe(leading, trailing)` method to your list item

```swift
List {
    HStack {
        Text("Enes Karaosman")
        Spacer()
    }
    .listRowInsets(EdgeInsets())
    .onSwipe(leading: [
      .. // here add slots
    ])
    
}
```

But what is `Slot`? <br>
It's just a container that wraps your elements

```swift
public struct Slot: Identifiable {
    
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
    public let imageColor: Color = .white
    
    /// Individual slot width
    public let slotWidth: CGFloat = 60
}
```

That's it, here is full working example

```swift
struct StackOverFlow: View {
    
    var slidableContent: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.secondary)
            .frame(height: 60)
            
            VStack(alignment: .leading) {
                Text("Enes Karaosman")
                .fontWeight(.semibold)
            
                Text("eneskaraosman53@gmail.com")
                .foregroundColor(.secondary)
            }
        }.padding()
    }
    
    var slots = [
        // First item
        Slot(
            image: {
                Image(systemName: "envelope.open.fill")
            },
            title: {
                Text("Read")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
                .embedInAnyView()
            },
            action: { print("Read Slot tapped") },
            style: .init(background: .orange)
        ),
        // Second item
        Slot(
            image: {
                Image(systemName: "hand.raised.fill")
            },
            title: {
                Text("Block")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
                .embedInAnyView()
            },
            action: { print("Block Slot Tapped") },
            style: .init(background: .blue, imageColor: .red)
        )
    ]
    
    var left2Right: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(leading: slots)
    }
    
    var right2Left: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(trailing: slots)
    }
    
    var leftAndRight: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(leading: slots, trailing: slots)
    }
    
    var items: [AnyView] {
        [
            left2Right.embedInAnyView(),
            right2Left.embedInAnyView(),
            leftAndRight.embedInAnyView()
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items.indices, id: \.self) { idx in
                    self.items[idx]
                }.listRowInsets(EdgeInsets())
            }.navigationBarTitle("Messages")
        }
    }
    
}
```

### Custom

In demo I used system images, but using local image is allowed as well.

```swift
ListItem
    .onSwipe(leading: [
        Slot(
            image: {
                Image("localImageName")
                    // To allow colorifying
                    .renderingMode(.template)
            },
            title: {
                Text("Title").embedInAnyView()
            },
            action: { print("Slot tapped") },
            style: .init(background: .orange)
        )
    ])
```
