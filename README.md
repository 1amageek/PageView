# PageView

```swift
    struct ContentView: View {

        var body: some View {
            Group {
                PageView {
                    ForEach(0..<2) { index in
                        Text("\(index)")
                    }
                }

                PageView {
                    ForEach(["a", "b"], id: \.self) { index in
                        Text("\(index)")
                    }
                }

                PageView {
                    Text("a")
                    Text("b")
                }
            }
        }
    }
```
