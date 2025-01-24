//
//  HapticManager.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private var generator: UIImpactFeedbackGenerator?
    
    private init() {
        setupGenerator()
    }
    
    func setupGenerator() {
        generator = UIImpactFeedbackGenerator()
        generator?.prepare()
    }
    
    func createImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        generator?.impactOccurred()
    }
    
    func release() {
        generator = nil
    }
}
