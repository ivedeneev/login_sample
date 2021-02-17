//
//  AccountManager.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import Foundation

protocol AccountManagerProtocol {
    var isLoggedIn: Bool { get }
}

final class AccountManager: AccountManagerProtocol {
    var isLoggedIn: Bool {
        return false
    }
}
