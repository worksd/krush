import SwiftUI
import SDWebImageSwiftUI
import LinkNavigator

struct MainNavigationView: View {
    let bootInfo: BootInfo
    let menuItems: [BottomMenuItem]
    let navigator: LinkNavigatorType

    @Binding var selectedRoute: String

    // ✅ 딥링크(bootInfo.route) 1회 처리 가드
    @State private var didHandleBootRoute: Bool = false

    init(
        bootInfo: BootInfo,
        menuItems: [BottomMenuItem],
        navigator: LinkNavigatorType,
        selectedRoute: Binding<String>
    ) {
        self.menuItems = menuItems
        self.navigator = navigator
        self._selectedRoute = selectedRoute
        self.bootInfo = bootInfo
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedRoute) {
                ForEach(menuItems, id: \.page.route) { item in
                    LazyTabContent(
                        navigator: navigator,
                        route: item.page.route,
                        isActive: selectedRoute == item.page.route
                    )
                    .tabItem {
                        Label {
                            Text(item.label)
                                .font(.system(size: CGFloat(item.labelSize)))
                        } icon: {
                            WebImage(
                                url: URL(string: item.iconUrl),
                                context: [.imageThumbnailPixelSize: CGSize(width: 24, height: 24)]
                            )
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        }
                    }
                    .tag(item.page.route)
                }
            }
            // ✅ 초기 탭 세팅은 별도 task로 유지
            .task {
                if selectedRoute.isEmpty {
                    selectedRoute = menuItems.first?.page.route ?? "/home"
                }
            }
        }
        .tint(.black)
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // ✅ onAppear 대신: route 값이 바뀔 때만 실행됨
        .task(id: bootInfo.route) {
            // route 없으면 패스
            guard !bootInfo.route.isEmpty else { return }
            // 이미 처리했으면 패스 (중복 push 방지)
            guard !didHandleBootRoute else { return }

            let routeInfo = try? JSONDecoder().decode(
                RouteInfo.self,
                from: Data(bootInfo.route.utf8)
            )

            guard routeInfo?.route != nil else { return }

            didHandleBootRoute = true
            print("boot route:", bootInfo.route)

            navigator.next(
                paths: ["web"],
                items: ["route": routeInfo?.toJSONString() ?? ""],
                isAnimated: true
            )
        }
    }
}

private struct LazyTabContent: View {
    let navigator: LinkNavigatorType
    let route: String
    let isActive: Bool

    var body: some View {
        Group {
            if isActive {
                WebView(navigator: navigator, route: route)
                    .id(route)
            } else {
                Color.clear
            }
        }
    }
}

public struct MainView: View {
    @State private var selectedRoute: String
    private let navigator: LinkNavigatorType
    private let menuItems: [BottomMenuItem]
    private let bootInfo: BootInfo

    public init(navigator: LinkNavigatorType, bootInfoCommand: String) {
        self.navigator = navigator

        let bootInfo: BootInfo = {
            guard let data = bootInfoCommand.data(using: .utf8) else {
                return BootInfo(bottomMenuList: [], route: "")
            }
            return (try? JSONDecoder().decode(BootInfo.self, from: data))
                ?? BootInfo(bottomMenuList: [], route: "")
        }()
        self.bootInfo = bootInfo
        self.menuItems = bootInfo.bottomMenuList

        _selectedRoute = State(initialValue: "/home")
    }

    public var body: some View {
        MainNavigationView(
            bootInfo: bootInfo,
            menuItems: menuItems,
            navigator: navigator,
            selectedRoute: $selectedRoute
        )
    }
}
