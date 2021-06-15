//
//  TabViewCell.swift
//  SnapList
//
//  Created by hiraoka on 2021/06/08.
//

import SwiftUI

struct TabViewCell: View {
    let colors: [Color]
    @State private var selection: Int = .zero

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(zip(colors.indices, colors)), id: \.0) { (index, color) in
                color.tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
//        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct TabViewCell_Previews: PreviewProvider {
    static var previews: some View {
        TabViewCell(colors: [.blue, .red, .green, .yellow, .black])
    }
}
