//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2021/02/03.
//

import SwiftUI
import PageView

struct Item: Identifiable, Hashable {
    var id: String
}

struct ContentView: View {

    @State var selection: Item?

    var body: some View {

        PageView($selection) {
            ForEach([
                Item(id: "0"),
                Item(id: "1"),
                Item(id: "2"),
                Item(id: "3"),
                Item(id: "4")
            ], id: \.self) { index in
                VStack {
                    Text("\(index.id)")
                    HStack {
                        Button {
                            self.selection = Item(id: "0")
                        } label: {
                            Text("prev")
                        }

                        Button {
                            self.selection = Item(id: "4")
                        } label: {
                            Text("next")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
