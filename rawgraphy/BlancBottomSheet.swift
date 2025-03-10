//
//  BottomSheet.swift
//  rawgraphy
//
//  Created by 이동호 on 3/8/25.
//

import SwiftUI
import LinkNavigator
import BottomSheet

struct BlancBottomSheet {
    
    let navigator: LinkNavigatorType
    let route: String
    @State var bottomSheetPosition: BottomSheetPosition = .absoluteBottom(100)
}

extension WebView: View {
    public var body: some View {
        ZStack {
            
        }
        .navigationBarHidden(true)
        .bottomSheet(bottomSheetPosition: $bottomSheetPosition, switchablePositions: [], content: {
            RawgraphyWebView(navigator: navigator, route: route)
        })
    }
}
