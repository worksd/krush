import SwiftUI
import LinkNavigator

public struct WebView {
    let navigator: LinkNavigatorType
    let route: String
    let title: String?
    let ignoreSafeArea: Bool?
    
    init(navigator: LinkNavigatorType, route: String, loadFailed: Bool = false) {
        self.navigator = navigator
        let routeInfo = (try? JSONDecoder().decode(RouteInfo.self, from: Data(route.utf8)))
        self.route = routeInfo?.route ?? route
        self.ignoreSafeArea = routeInfo?.ignoreSafeArea
        self.title = routeInfo?.title
        self.loadFailed = loadFailed
        print("WebView")
        print("route = \(self.route) ignoreSafeArea = \(String(describing: self.ignoreSafeArea))")
    }

    // ✅ 추가: 에러 상태 & 리로드 토큰
    @State private var loadFailed = false
}

extension WebView: View {
    public var body: some View {
        ZStack {
            RawgraphyWebView(
                navigator: navigator,
                route: route,
                loadFailed: $loadFailed
            )

            if route == "/splash" {
                Color.black.ignoresSafeArea()
                Image("Logo")
            }

            // ✅ 네트워크 실패 시 에러 오버레이
            if loadFailed {
                ZStack {
                    // 전체 화면 딤 처리
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    // 팝업 컨텐츠
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 44, weight: .semibold))

                        // 제목
                        VStack(spacing: 4) {
                            Text("연결에 실패했어요")
                                .font(.headline)
                            Text("Failed to connect")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // 부가 설명
                        VStack(spacing: 4) {
                            Text("네트워크를 확인한 뒤 다시 시도해 주세요.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Please check your network and try again.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Button(action: {
                            navigator.back(isAnimated: true)
                        }) {
                            Text("닫기")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
                .zIndex(1) // 전체 뷰 위에 확실히 올라오도록
            }
        }
        .navigationBarHidden(true)
        .modifier(SafeAreaModifier(enabled: ignoreSafeArea == true))
        .safeAreaInset(edge: .top, spacing: 0) {
            if let title {
                TitleBar(
                    title: title,
                    onBack: {
                        // 네이티브 네비 우선
                        navigator.back(isAnimated: true)
                    }
                )
            }
        }
    }
}

private struct SafeAreaModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.ignoresSafeArea()
        } else {
            content
        }
    }
}


private struct TitleBar: View {
    let title: String
    var onBack: () -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .foregroundColor(.black)
                        .clipShape(Circle())
                }
                .contentShape(Rectangle())

                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8) // 하단 여백으로 시각적 균형
        }
        .frame(height: 56)       // 타이틀바 자체 높이(안전영역 제외)
    }
}
