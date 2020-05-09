# SwipeCell

### Preview
![](https://github.com/EnesKaraosman/SwipeCell/blob/master/Sources/SwipeCell/Resources/swipe_cell.png)

![](https://github.com/EnesKaraosman/SwipeCell/blob/master/Sources/SwipeCell/Resources/swipe_cell_l2r.gif)

### Features

* Swipe cell from Left to Right

### Todo

* Add Right to Left swipe
* Add destructive swipe

### Usage

* Simply add `swipeFromLeading` method to your list item

```swift
List {
  Text("Here is my content")
    .swipeFromLeading(slots: [
      .. // here add slots
    ])
    
}
```

But what is `Slot`? <br>
It's just a container that wraps your elements

```swift
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
    public let imageColor: Color = .white
    /// Individual slot width
    public let slotWidth: CGFloat = 60
}
```

That's it, here is full working example

```swift
struct SwipeCellDemoView: View {
    
    @State var dynamicHeight: CGFloat = 60
    
    // Dummy list item content
    var slidableContent: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.secondary)
                .frame(height: self.dynamicHeight)
            VStack(alignment: .leading) {
                Text("Enes Karaosman")
                    .fontWeight(.semibold)
                Text("eneskaraosman53@gmail.com")
                    .foregroundColor(.secondary)
            }
        }.padding()
    }
    
    var body: some View {
        NavigationView {
            List {
                
                ForEach(0...3, id: \.self) { idx in
                    
                    self.slidableContent
                        .swipeFromLeading(slots: [
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
                                        .embedInAnyView() // Wraps with AnyView ( .. )
                                },
                                action: { print("Read Slot tapped \(idx)") },
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
                                        .embedInAnyView() // Wraps with AnyView ( .. )
                                },
                                action: { print("Block Slot Tapped \(idx)") },
                                style: .init(background: .blue, imageColor: .red)
                            )
                        ])
                    
                }
                .listRowInsets(EdgeInsets()) // Required for Slot's height
                
                // Play with slider to see how slot's height adopts
                Slider(value: $dynamicHeight.animation(), in: 40...100)
                
            }.navigationBarTitle("Messages")
        }
        
    }
}
```

### Custom

In demo I used system images, but using local image is allowed as well.

```swift
ListItem
    .swipeFromLeading(slots: [
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
