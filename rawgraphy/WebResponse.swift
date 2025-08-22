//
//  TabItem.swift
//  rawgraphy
//
//  Created by 이동호 on 2025/01/01.
//

import Foundation

// MARK: - 데이터 모델
struct BootInfo: Codable {
    let bottomMenuList: [BottomMenuItem]
    let route: String
}

struct BottomMenuItem: Codable {
    let label: String
    let labelSize: Int
    let iconUrl: String
    let iconSize: Int
    let page: Page
}

struct Page: Codable {
    let route: String
    let initialColor: String
}

struct PaymentInfo: Codable {
    let channelKey: String
    let storeId: String
    let paymentId: String
    let price: Int
    let method: String
    let orderName: String
    let userId: String
    let customData: String
}

struct CustomerInfo: Codable {
    let name: String
}
