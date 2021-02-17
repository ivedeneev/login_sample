//
//  Tariff.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import Foundation

struct Tariff: Decodable {
    let title: String
    let type: Level
    let price: Int
    let hasDiscount: Bool
    let isPriceIncreased: Bool
    
    enum Level: String, Decodable {
        case econom
        case comfort
        case business
        case lux
    }
}

extension Tariff.Level {
    var iconName: String {
        switch self {
        case .econom:
            return "bentley"
        case .comfort:
            return "bentley"
        case .business:
            return "bentley"
        case .lux:
            return "bentley"
        }
    }
}
