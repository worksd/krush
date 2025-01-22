//
//  SVGImage.swift
//  rawgraphy
//
//  Created by 이동호 on 1/17/25.
//

import UIKit
import Kingfisher
import SVGKit

struct SVGProcessor: ImageProcessor {
    
    // 고유 식별자로, 캐싱 시 이 프로세서가 처리한 이미지를 구별하기 위해 사용됩니다.
    var identifier: String = "jayvenIdentifier"
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            // 이미 Image 객체가 있는 경우, 변환 없이 해당 이미지를 반환합니다.
            return image
            
        case .data(let data):
            // SVG 데이터로부터 UIImage를 생성합니다.
            // 실패할 경우 DefaultImageProcessor를 사용하여 처리합니다.
            return generateSVGImage(data: data)
            ?? DefaultImageProcessor().process(item: item, options: options)
            
        }
    }
}

// SVG 이미지 캐싱을 위한 CacheSerializer
private struct SVGCacheSerializer: CacheSerializer {
    
    // 이미지를 캐시에 저장할 때 사용할 데이터 변환 함수
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data? {
        return original
    }
    
    // 캐시된 데이터로부터 이미지를 생성하는 함수
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        return generateSVGImage(data: data) ?? image(with: data, options: options)
    }
}

private func generateSVGImage(data: Data) -> UIImage? {
    // SVGKImage를 사용하여 SVG 데이터를 처리하고 UIImage 객체로 변환합니다.
    guard let svgImage = SVGKImage(data: data) else { return nil }
    return svgImage.uiImage
}

