//
//  ProfileViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import RxSwift


final class ProfileViewController: CollectionViewController {
    
    var viewModel: ProfileViewModelProtocol!
    
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
                self.viewModel.showSettings.onNext(())
            }
        director += settingsSection
        
        director.reload()
    }
}

final class ProfileCoordinator: BaseCoordinator<Void> {
    
    private let disposeBag = DisposeBag()
    
    init(_ rootVc: UIViewController?) {
        super.init()
        rootViewController = rootVc
    }
    
    override func start() -> Observable<Void> {
        let vc = ProfileViewController()
        let vm = ProfileViewModel()
        vc.viewModel = vm
        
        let nc = TranslucentNavigationController(rootViewController: vc)
        
        rootViewController?.present(nc, animated: true, completion: nil)
        
        vm.didShowSettings
            .flatMap { [unowned self] in
                self.showSettings(in: nc)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func showSettings(in nc: UINavigationController) -> Observable<Void> {
        let coordinator = SettingsCoordinator(rootViewController: nc)
        return coordinate(to: coordinator)
    }
}

protocol ProfileViewModelProtocol {
    var showSettings: AnyObserver<Void> { get }
    var didShowSettings: Observable<Void> { get }
}

final class ProfileViewModel: ProfileViewModelProtocol {
    var showSettings: AnyObserver<Void>
    var didShowSettings: Observable<Void>
    
    init() {
        let _settings = PublishSubject<Void>()
        showSettings = _settings.asObserver()
        didShowSettings = _settings.asObservable()
    }
}
