//
//  Card.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 08.02.2021.
//

import Foundation

struct Card: Decodable {
    let id = UUID().uuidString
    let name: String
    let issuer: Issuer
    
    enum Issuer: String, Decodable {
        case visa
        case mastercard
        case other
        
        var icon: String {
            switch self {
            default:
                return rawValue
            }
        }
    }
}

enum PaymentMethod {
    case cash
    case card(Card)
    case applePay
    
    var name: String {
        switch self {
        case .cash:
            return "Наличные"
        case .applePay:
            return "Apple Pay"
        case .card(let card):
            return card.name
        }
    }
    
    var icon: String {
        switch self {
        case .card(let card):
            return card.issuer.icon
        case .applePay:
            return "apple_pay"
        case .cash:
            return "cash"
        }
    }
}
