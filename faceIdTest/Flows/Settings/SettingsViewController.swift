//
//  SettingsViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 26.02.2021.
//

import UIKit
import RxSwift
import LocalAuthentication
import RxRelay

final class SettingsViewController: CollectionViewController {
    var viewModel: SettingsViewModel!
    let enablePin: Observable<Void>
    private let _enablePin: PublishSubject<Void>
    private let disposeBag = DisposeBag()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _enablePin = PublishSubject<Void>()
        enablePin = _enablePin.share().asObservable()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = CollectionSection()
        let pin = ToggleCellViewModel(title: "Использовать Pin", isOn: false)
        section += CollectionItem<ToggleCell>(item: pin)
        
        let faceId = ToggleCellViewModel(title: "Вход по FaceID", isOn: false)
        section += CollectionItem<ToggleCell>(item: faceId)
        section += CollectionItem<CommonCell>(item: .init(title: "Изменить Pin", subtitle: nil, icon: nil))
            .onSelect { [weak self] _ in
                self?.viewModel.editPin.onNext(())
            }
        
        let isOnValues = pin.isOnRelay.skip(2).share()

        director += section
        director.reload()
        
        isOnValues
            .filter { $0 }
            .mapToVoid()
            .bind(to: viewModel.showEnablePin)
            .disposed(by: disposeBag)
        
        viewModel.didCancelEnablePin
            .mapTo(false)
            .bind(to: pin.isOnRelay)
            .disposed(by: disposeBag)
        
//        isOnValues
//            .filter { !$0 }
//            .mapToVoid()
//            .bind(to: viewModel.editPin)
//            .disposed(by: disposeBag)
    }
}
