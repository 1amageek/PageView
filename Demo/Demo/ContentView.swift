//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2021/02/03.
//

import SwiftUI
import PageView

struct ContentView: View {

    @State var selection: Int = 0

    var body: some View {

        PageView($selection) {
            ForEach([0, 2, 4], id: \.self) { index in
                VStack {
                    Text("\(index)")
                    HStack {
                        Button {
                            self.selection -= 1
                        } label: {
                            Text("prev")
                        }

                        Button {
                            self.selection += 1
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
