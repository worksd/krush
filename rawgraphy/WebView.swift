import SwiftUI
import LinkNavigator

public struct WebView {
    let navigator: LinkNavigatorType
    let route: String

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
                .background(.thinMaterial)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
    }
}
