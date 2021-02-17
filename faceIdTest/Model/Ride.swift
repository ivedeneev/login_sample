//
//  Ride.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import Foundation


struct Ride: Decodable {
    let from: Address
    let to: Address?
    let estimatedTime: Double?
    let tariffs: [Tariff]
}
