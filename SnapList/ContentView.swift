//
//  ContentView.swift
//  SnapList
//
//  Created by hiraoka on 2021/06/08.
//

import Combine
import SwiftUI

struct ContentView: View {
    struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = .zero

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value += nextValue() }
    }

    private let colorsArray: [[Color]] = [[.blue, .red, .green, .yellow, .black],
                                          [.red, .green, .yellow, .black, .blue],
                                          [.green, .yellow, .black, .blue, .red],
                                          [.yellow, .black, .blue, .red, .green],
                                          [.black, .blue, .red, .green, .yellow],
                                          [.blue, .red, .green, .yellow, .black]]

    let scrollOffsetSubject: PassthroughSubject<CGFloat, Never> = .init()
    @State private var selection: Int = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: .zero) {
                        ForEach(Array(zip(colorsArray.indices, colorsArray)), id: \.0) { (index, colors) in
                            TabViewCell(colors: colors)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(index)
                        }
                    }
                    .background( GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self, value: -(geometry.frame(in: .named("scroll")).origin.y))
                    })
                    .onPreferenceChange(ScrollOffsetKey.self) { scrollOffsetSubject.send($0)}
                }
                .coordinateSpace(name: "scroll")
                .onReceive(scrollOffsetSubject.debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)) { newValue in
                    let currentIndex = newValue/geometry.size.height
                    let near = currentIndex < 1 ? currentIndex : currentIndex.truncatingRemainder(dividingBy: CGFloat(Int(currentIndex)))
                    let newIndex = near > 0.5 ? Int(currentIndex) + 1 : Int(currentIndex)
                    withAnimation { scroll.scrollTo(newIndex, anchor: .center) }
                }
                .onAppear {
                    UIScrollView().decelerationRate = .fast
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
