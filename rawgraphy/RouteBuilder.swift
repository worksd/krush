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
