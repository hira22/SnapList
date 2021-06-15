//
//  SnapScrollingModifier.swift
//  SnapList
//
//  Created by hiraoka on 2021/06/10.
//

import SwiftUI

struct SnapScrollingModifier: ViewModifier {

    @State private var scrollOffset: CGFloat
    @State private var dragOffset: CGFloat

    var items: Int
    var itemHeight: CGFloat
    var itemSpacing: CGFloat

    init(items: Int, itemHeight: CGFloat, itemSpacing: CGFloat) {
        self.items = items
        self.itemHeight = itemHeight
        self.itemSpacing = itemSpacing

        // Calculate Total Content Height
        let contentHeight: CGFloat = CGFloat(items) * itemHeight + CGFloat(items - 1) * itemSpacing
        let screenHeight = UIScreen.main.bounds.height

        // Set Initial Offset to first Item
        let initialOffset = (contentHeight/2.0) - (screenHeight/2.0) + ((screenHeight - itemHeight) / 2.0)

        self._scrollOffset = State(initialValue: initialOffset)
        self._dragOffset = State(initialValue: 0)
    }

    func body(content: Content) -> some View {
        content
            .offset(x: scrollOffset + dragOffset, y: 0)
            .gesture(DragGesture()
                        .onChanged({ event in
                dragOffset = event.translation.height
            })
                        .onEnded({ event in
                // Scroll to where user dragged
                scrollOffset += event.translation.height
                dragOffset = 0

                // Now calculate which item to snap to
                let contentHeight: CGFloat = CGFloat(items) * itemHeight + CGFloat(items - 1) * itemSpacing
                let screenHeight = UIScreen.main.bounds.height

                // Center position of current offset
                let center = scrollOffset + (screenHeight / 2.0) + (contentHeight / 2.0)

                // Calculate which item we are closest to using the defined size
                var index = (center - (screenHeight / 2.0)) / (itemHeight + itemSpacing)

                // Should we stay at current index or are we closer to the next item...
                if index.remainder(dividingBy: 1) > 0.5 {
                    index += 1
                } else {
                    index = CGFloat(Int(index))
                }

                // Protect from scrolling out of bounds
                index = min(index, CGFloat(items) - 1)
                index = max(index, 0)

                // Set final offset (snapping to item)
                let newOffset = index * itemHeight + (index - 1) * itemSpacing - (contentHeight / 2.0) + (screenHeight / 2.0) - ((screenHeight - itemHeight) / 2.0) + itemSpacing

                // Animate snapping
                withAnimation {
                    scrollOffset = newOffset
                }

            })
            )
    }
}
