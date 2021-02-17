//
//  MyAddressesController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit

final class MyAddressesController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = CollectionSection()
        section += CollectionItem<ProfileHeaderCell>(item: User(name: "Мои адреса", phone: "", favoriteAddresses: [], cards: []))
        section += CollectionItem<CommonCell>(item: .init(title: "Дом", subtitle: "Авиационная 68", icon: "camera"))
        section += CollectionItem<CommonCell>(item: .init(title: "Работа", subtitle: "Петровка 19/4", icon: "camera"))
        director += section
        director.reload()
    }
}
