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
import IVCollectionKit
import RxSwiftExt

final class SettingsViewController: CollectionViewController {
    var viewModel: SettingsViewModel!
//    let enablePin: Observable<Void>
//    private let _enablePin: PublishSubject<Void>
    private let disposeBag = DisposeBag()
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        _enablePin = PublishSubject<Void>()
//        enablePin = _enablePin.share().asObservable()
//        
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs = Preferences()
        let section = CollectionSection()
        let pin = ToggleCellViewModel(title: "Использовать Pin", isOn: prefs.pinIsOn)
        section += CollectionItem<ToggleCell>(item: pin)
        
        let faceId = ToggleCellViewModel(title: "Вход по FaceID", isOn: prefs.biometricsIsOn)
        section += CollectionItem<ToggleCell>(item: faceId)

        let editPin = CollectionItem<CommonCell>(item: .init(title: "Изменить Pin", subtitle: nil, icon: nil))
        section += editPin

        editPin.reactive.onSelectObservable
            .mapToVoid()
            .do(onDispose: {
                print("dispose")
            })
            .bind(to: viewModel.editPin)
            .disposed(by: disposeBag)
        
        let isOnValues = pin.isOnRelay.skip(2).share()
        let faceIdValues = faceId.isOnRelay.skip(2)
        
        let themeSection = CollectionSection()
        
        director += section
        director += themeSection
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
        
        faceIdValues
            .bind(to: viewModel.toggleBiometrics)
            .disposed(by: disposeBag)
    }
}

extension CollectionItem: ReactiveCompatible {}
//extension Reactive where Base: CollectionItem<ToggleCell> {
//    var onSelect: Observable
//}
