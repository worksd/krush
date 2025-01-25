//
//  RouteBuilder.swift
//  rawgraphy
//
//  Created by 이동호 on 1/22/25.
//

import LinkNavigator
import SwiftUI

struct WebRouteBuilder: RouteBuilder {
  var matchPath: String { "web" }

  var build: (LinkNavigatorType, [String: String], DependencyType) -> MatchingViewController? {
    { navigator, items, dependency in
      return WrappingController(matchPath: matchPath) {
          WebView(navigator: navigator, route: items["route"] ?? "")
      }
    }
  }
}

struct MainRouteBuilder: RouteBuilder {
  var matchPath: String { "main" }

  var build: (LinkNavigatorType, [String: String], DependencyType) -> MatchingViewController? {
    { navigator, items, dependency in
      return WrappingController(matchPath: matchPath) {
          MainView(navigator: navigator, bootInfoCommand: items["bootInfo"] ?? "")
      }
    }
  }
}

struct DialogRouteBuilder: RouteBuilder {
    var matchPath: String { "dialog" }
    
    var build: (LinkNavigatorType, [String: String], DependencyType) -> MatchingViewController? {
        { navigator, items, dependency in
            guard let dialogInfoString = items["dialogInfo"],
                  let dialogInfo = try? JSONDecoder().decode(KloudDialogInfo.self, from: dialogInfoString.data(using: .utf8) ?? Data()) else {
                return nil
            }
            
            return WrappingController(matchPath: matchPath) {
                if dialogInfo.type == "IMAGE" {
                    ImageDialogScreen(
                        id: dialogInfo.id,
                        hideForeverMessage: dialogInfo.hideForeverMessage,
                        imageUrl: dialogInfo.imageUrl ?? "",
                        imageRatio: dialogInfo.imageRatio ?? 1.0,
                        ctaButtonText: dialogInfo.ctaButtonText,
                        onDismiss: {
                            navigator.back(isAnimated: true)
                        },
                        onClick: { id in
                            if let route = dialogInfo.route {
                                navigator.next(paths: [route], items: [:], isAnimated: true)
                            }
                        },
                        onClickHideDialog: { id, isHidden in
                            // 필요한 경우 hideDialog 처리
                        }
                    )
                } else {
                    // SIMPLE 타입 다이얼로그 처리
                    EmptyView()
                }
            }
        }
    }
}
