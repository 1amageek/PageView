//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2021/02/03.
//

import SwiftUI
import PageView


struct ContentView: View {

    @State var navigation: PageNavigation = .init(0)

    var body: some View {
        PageView([
            Button("0", action: {
                self.navigation.page += 1
            }),
            Button("1", action: {
                self.navigation.page += 1
            }),
            Button("2", action: {
                self.navigation = .reverse(0)
            })
        ], navigation: $navigation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
