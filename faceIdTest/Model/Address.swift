//
//  Address.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import Foundation


struct Address: Decodable {
    let id = UUID().uuidString
    let name: String
    let lat: Double
    let lon: Double
}
