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
            navigator: navigator, showDialog: { dialogInfo in
                withAnimation {
                    currentDialog = dialogInfo
                    showDialog = true
                }
            }
        ).overlay {
            DialogOverlay(
                isShowing: showDialog,
                dialogInfo: currentDialog,
                navigator: navigator,
                onDismiss: {
                    withAnimation {
                        showDialog = false
                    }
                }
            )
        }
    }
}

struct MainNavigationView: View {
    
    let menuItems: [BottomMenuItem]
    let navigator: LinkNavigatorType
    let showDialog: (KloudDialogInfo) -> Void
    
    var body: some View {
        NavigationView {
            TabView{
                ForEach(menuItems.indices, id: \.self) { index in
                    RawgraphyWebView(
                        navigator: navigator,
                        route: menuItems[index].page.route,
                        showDialog: showDialog
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

struct DialogOverlay: View {
    let isShowing: Bool
    let dialogInfo: KloudDialogInfo?
    let navigator: LinkNavigatorType
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if isShowing, let info = dialogInfo {
                Color.black.opacity(0.5)
                    .onTapGesture(perform: onDismiss)
                
                KloudDialog(
                    dialogInfo: info,
                    onClick: { info in
                        WebViewContainer.shared.sendWebEvent(functionName: "onDialogConfirm", data: [
                            "id": info.id,
                            "type": info.type,
                            "route": info.route,
                            "hideForeverMessage": info.hideForeverMessage,
                            "imageUrl": info.imageUrl,
                            "imageRatio": info.imageRatio,
                            "title": info.title,
                            "message": info.message,
                            "ctaButtonText": info.ctaButtonText
                        ])
                        onDismiss()
                    },
                    onClickHideDialog: { id, isHidden in
                        WebViewContainer.shared.sendWebEvent(functionName: "onHideDialogConfirm", data: [
                            "id": id,
                            "clicked": isHidden
                        ])
                    },
                    onDismiss: onDismiss
                )
                .padding(.horizontal, 20)
            }
        }.ignoresSafeArea()
    }
}

