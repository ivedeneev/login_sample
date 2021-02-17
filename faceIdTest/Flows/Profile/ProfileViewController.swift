//
//  ProfileViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import RxSwift


final class ProfileViewController: CollectionViewController {
    
    lazy var logoImageView = UIImageView(image: UIImage(named: "Logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
        
        let headerSection = CollectionSection()
        headerSection += CollectionItem<ProfileHeaderCell>(item: User(name: "Константин", phone: "+79153051653", favoriteAddresses: [], cards: []))
        headerSection.insetForSection = UIEdgeInsets(top: 16, left: 0, bottom: 48, right: 0)
        director += headerSection
        
        let settingsSection = CollectionSection()
        settingsSection.lineSpacing = 4
        settingsSection += CollectionItem<CommonCell>(item: .init(title: "Мои адреса", subtitle: nil, icon: nil))
            .onSelect { [unowned self] _ in
                self.navigationController?.pushViewController(MyAddressesController(), animated: true)
            }
        settingsSection += CollectionItem<CommonCell>(item: .init(title: "История поездок", subtitle: nil, icon: nil))
        settingsSection += CollectionItem<CommonCell>(item: .init(title: "Способы оплаты", subtitle: "Apple Pay", icon: nil))
            .onSelect { [unowned self] _ in
                self.navigationController?.pushViewController(PaymentMethodsController(), animated: true)
            }
        
        settingsSection += CollectionItem<CommonCell>(item: .init(title: "Настройки", subtitle: nil, icon: nil))
            .onSelect { [unowned self] _ in
                self.navigationController?.pushViewController(PaymentMethodsController(), animated: true)
            }
        director += settingsSection
        
        director.reload()
    }
}

final class ProfileCoordinator: BaseCoordinator<Void> {
    
    init(_ rootVc: UIViewController?) {
        super.init()
        rootViewController = rootVc
    }
    
    
    override func start() -> Observable<Void> {
        let vc = ProfileViewController()
        
        
        let nc = TranslucentNavigationController(rootViewController: vc)
        
        rootViewController?.present(nc, animated: true, completion: nil)
        
        return .never()
    }
}
