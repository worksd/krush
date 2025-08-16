import SwiftUI
import SDWebImageSwiftUI
import LinkNavigator

struct MainNavigationView: View {
    let menuItems: [BottomMenuItem]
    let navigator: LinkNavigatorType
    @Binding var selectedRoute: String   // ✅ Binding으로 선언

    // ✅ 명시적 이니셜라이저 (Binding 주입)
    init(menuItems: [BottomMenuItem],
         navigator: LinkNavigatorType,
         selectedRoute: Binding<String>) {
        self.menuItems = menuItems
        self.navigator = navigator
        self._selectedRoute = selectedRoute
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
            .task {
                // 부모에서 비어 있는 값으로 내려온 경우만 기본값 세팅
                if selectedRoute.isEmpty {
                    selectedRoute = menuItems.first?.page.route ?? "/home"
                }
            }
        }
        .tint(.black)
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LazyTabContent: View {
    let navigator: LinkNavigatorType
    let route: String
    let isActive: Bool

    var body: some View {
        Group {
            if isActive {
                WebView(navigator: navigator, route: route) // ✅ 선택 탭만 생성
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

    public init(navigator: LinkNavigatorType, bootInfoCommand: String) {
        self.navigator = navigator

        // 1) bootInfo 디코딩
        let bootInfo: BootInfo = {
            guard let data = bootInfoCommand.data(using: .utf8) else {
                return BootInfo(bottomMenuList: [], route: "")
            }
            return (try? JSONDecoder().decode(BootInfo.self, from: data))
                ?? BootInfo(bottomMenuList: [], route: "")
        }()

        // 2) 메뉴 주입
        self.menuItems = bootInfo.bottomMenuList

        // 3) 초기 탭 결정: bootInfo.route가 메뉴에 있으면 그거, 아니면 첫 탭, 없으면 "/home"
        let initial: String = {
            if !bootInfo.route.isEmpty,
               bootInfo.bottomMenuList.contains(where: { $0.page.route == bootInfo.route }) {
                return bootInfo.route
            }
            return bootInfo.bottomMenuList.first?.page.route ?? "/home"
        }()

        _selectedRoute = State(initialValue: initial)
    }

    public var body: some View {
        MainNavigationView(
            menuItems: menuItems,
            navigator: navigator,
            selectedRoute: $selectedRoute
        )
    }
}
