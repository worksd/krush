//
//  WebView.swift
//  rawgraphy
//
//  Created by 이동호 on 1/22/25.
//
import SwiftUI
import LinkNavigator

public struct WebView {
    
    let navigator: LinkNavigatorType
    let route: String
}

extension WebView: View {
    public var body: some View {
        ZStack {
            RawgraphyWebView(navigator: navigator, route: route, showDialog: { _ in })
            if route == "/splash" {
                Color.black
                Image("Logo")
            }
        }
        .navigationBarHidden(true)
    }
}
