# PageView

```swift
struct ContentView: View {

    @State var navigation: PageNavigation = 0

    var body: some View {
        PageView([
            Button("0", action: {
                self.navigation.page += 1
            }),
            Button("1", action: {
                self.navigation = .direct(2)
            }),
            Button("2", action: {
                self.navigation = .reverse(0)
            })
        ], navigation: $navigation)
    }
}
```
