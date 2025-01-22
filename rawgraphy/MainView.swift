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
    @State private var selectedTab = 0
    @State private var menuItems: [BottomMenuItem] = []
    let navigator: LinkNavigatorType

    init(navigator: LinkNavigatorType, bootInfoCommand: String) {
        self.navigator = navigator
        let bootInfo = (try? JSONDecoder().decode(BootInfo.self, from: bootInfoCommand)) ?? BootInfo(bottomMenuList: [], route: "")
        self._menuItems = State(initialValue: bootInfo.bottomMenuList)
    }
}

extension MainView: View {
    public var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ForEach(self.menuItems.indices, id: \.self) { index in
                    RawgraphyWebView(
                        navigator: navigator,
                        route: self.menuItems[index].page.route
                    )
                    .tabItem {
                        let menuItem = menuItems[index]
                        Label {
                            Text(menuItem.label)
                                .font(.system(size: CGFloat(menuItem.labelSize)))
                        } icon: {
//                                WebImage(url: URL(string: menuItem.iconUrl))
//                                    .resizable()
//                                    .renderingMode(.template)
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: CGFloat(menuItem.iconSize),
//                                           height: CGFloat(menuItem.iconSize))
                            Image("photo")
                        }
                    }
                    .tag(index)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(.black)
        .preferredColorScheme(.light)
    }
}
