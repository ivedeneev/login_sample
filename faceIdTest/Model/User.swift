//
//  User.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 05.02.2021.
//

import Foundation


struct User: Decodable {
    let name: String
    let phone: String
    let favoriteAddresses: [Address]
    let cards: [Card]
    // selected payment method
}
