//
//  MainView.swift
//  rawgraphy
//
//  Created by 이동호 on 2025/01/01.
//

import Foundation
import SwiftUI

public struct MainView {
    @State private var selectedTab = 0
    @State private var menuItems: [BottomMenuItem] = []
    private var push: (String) -> Void
    private var clearAndPush : (String) -> Void
    
    init(
        bootInfo: BootInfo,
        push: @escaping (String) -> Void = { _ in },
        clearAndPush: @escaping (String) -> Void = { _ in }
    ) {
        _menuItems = State(initialValue: bootInfo.bottomMenuList) // @State 변수 초기화 수정
       print("MainView init with menuItems count: \(bootInfo.bottomMenuList.count)")
       bootInfo.bottomMenuList.forEach { item in
           print("Menu item: \(item.label), route: \(item.page.route)")
       }
        self.push = push
        self.clearAndPush = clearAndPush
    }
}

extension MainView: View {
    public var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()  // SafeArea까지 흰색으로 채움
                
                TabView {
                    ForEach(self.menuItems.indices, id: \.self) { index in
                        WebView(
                            route: self.menuItems[index].page.route,
                            sendBootInfo: { bootInfo in
                                
                            },
                            clearAndPush: { route in
                                clearAndPush(route)
                            },
                            push: { route in
                                push(route)
                            },
                            back: {
                                
                            }
                        )
                        .tabItem {
                            Image(systemName: "photo")
                                .frame(width: CGFloat(menuItems[index].iconSize),
                                     height: CGFloat(menuItems[index].iconSize))
                            
                            Text(menuItems[index].label)
                                .font(.system(size: CGFloat(menuItems[index].labelSize)))
                        }
                        .tag(index)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(.black)
        .preferredColorScheme(.light)  // 항상 라이트 모드 강제
        .background(Color.white.ignoresSafeArea())  // 전체 배경 흰색으로
    }
}
