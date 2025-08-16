import SwiftUI
import LinkNavigator

public struct WebView {
    let navigator: LinkNavigatorType
    let route: String
}

extension WebView: View {
    public var body: some View {
        ZStack {
            RawgraphyWebView(navigator: navigator, route: route)
            if route == "/splash" {
                Color.black.ignoresSafeArea()
                Image("Logo")
            }
        }
        .navigationBarHidden(true)
    }
}
