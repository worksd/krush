//
//  AppRouterGroup.swift
//  rawgraphy
//
//  Created by 이동호 on 1/22/25.
//

import LinkNavigator

struct AppRouterGroup {
  var routers: [RouteBuilder] {
    [
      WebRouteBuilder(),
      MainRouteBuilder()
    ]
  }
}
