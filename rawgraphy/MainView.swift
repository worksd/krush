//
//  MainView.swift
//  rawgraphy
//
//  Created by 이동호 on 2025/01/01.
//

import SwiftUI
import SDWebImageSwiftUI
import LinkNavigator

public struct MainView {
    @State private var currentDialog: KloudDialogInfo?
    @State private var showDialog = false
    let navigator: LinkNavigatorType
    let menuItems: [BottomMenuItem]

    init(navigator: LinkNavigatorType, bootInfoCommand: String) {
        self.navigator = navigator
        let bootInfo = (try? JSONDecoder().decode(BootInfo.self, from: bootInfoCommand)) ?? BootInfo(bottomMenuList: [], route: "")
        self.menuItems = bootInfo.bottomMenuList
        
    }
}

extension MainView: View {
    public var body: some View {
        MainNavigationView(
            menuItems: menuItems,
            navigator: navigator
        )
    }
}

struct MainNavigationView: View {
    
    let menuItems: [BottomMenuItem]
    let navigator: LinkNavigatorType
    
    var body: some View {
        NavigationView {
            TabView{
                ForEach(menuItems.indices, id: \.self) { index in
                    RawgraphyWebView(
                        navigator: navigator,
                        route: menuItems[index].page.route
                    )
                    .tabItem {
                        let menuItem = menuItems[index]
                        Label {
                            Text(menuItem.label)
                                .font(.system(size: CGFloat(menuItem.labelSize)))
                        } icon: {
                            WebImage(url: URL(string: menuItem.iconUrl), context: [.imageThumbnailPixelSize : CGSize(width: 24, height: 24)])
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .clipped()
                        }
                    }
                    .tag(index)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(.black)
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
