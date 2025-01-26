//
//  DeviceService.swift
//  rawgraphy
//
//  Created by 이동호 on 1/26/25.
//
import Foundation
import FirebaseMessaging

struct DeviceService: Codable {
    static func register(onComplete: @escaping() -> Void){
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              
          }
        }


    }
    static func unregister(onComplete: @escaping() -> Void){
        
    }
}
