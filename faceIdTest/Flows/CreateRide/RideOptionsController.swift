//
//  CreateRidePopoverViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import UIKit
import IVCollectionKit

final class RideOptionsController: BasePopover {
    
    override var minHeight: CGFloat { 0 }
    override var maxHeight: CGFloat { 350 }

    lazy var confirmButton = CommonButton(type: .custom)
    lazy var paymentMethodButton = CommonButton()
    lazy var rideOptionsButton = CommonButton()
    
    lazy var pointsView = RidePointsView()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    private lazy var director = CollectionDirector(collectionView: collectionView)
    private let section = CollectionSection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.background()
        
        view.addSubview(pointsView)
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Color.background()
        section.insetForSection = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        section.lineSpacing = 8
        section.minimumInterItemSpacing = 8
        collectionView.alwaysBounceHorizontal = true

        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Заказать", for: .normal)
        
        view.addSubview(paymentMethodButton)
        view.addSubview(rideOptionsButton)
        paymentMethodButton.translatesAutoresizingMaskIntoConstraints = false
        rideOptionsButton.translatesAutoresizingMaskIntoConstraints = false
//        paymentMethodButton.setTitle("ApplePay", for: .normal)
        rideOptionsButton.setTitle("Пожелания", for: .normal)
        paymentMethodButton.style = .default
        rideOptionsButton.style = .default
        paymentMethodButton.layer.cornerRadius = 0
        rideOptionsButton.layer.cornerRadius = 0
        rideOptionsButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
//        rideOptionsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            pointsView.topAnchor.constraint(equalTo: view.topAnchor),
            pointsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pointsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pointsView.heightAnchor.constraint(equalToConstant: 108),
            
            collectionView.topAnchor.constraint(equalTo: pointsView.bottomAnchor, constant: 2),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 90),
            
            paymentMethodButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            paymentMethodButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentMethodButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            paymentMethodButton.heightAnchor.constraint(equalToConstant: 48),
            
            rideOptionsButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            rideOptionsButton.leadingAnchor.constraint(equalTo: paymentMethodButton.trailingAnchor),
            rideOptionsButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            rideOptionsButton.heightAnchor.constraint(equalToConstant: 48),

            confirmButton.topAnchor.constraint(equalTo: paymentMethodButton.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        section.removeAll()
        let eco = Tariff(title: "Эконом", type: .econom, price: 330, hasDiscount: false, isPriceIncreased: false)
        let comfort = Tariff(title: "Комфорт", type: .econom, price: 415, hasDiscount: false, isPriceIncreased: false)
        let comfortPlus = Tariff(title: "Комфорт плюс", type: .econom, price: 634, hasDiscount: false, isPriceIncreased: false)
        let business = Tariff(title: "Комфорт плюс", type: .econom, price: 634, hasDiscount: false, isPriceIncreased: false)
        let viewModels = [eco, comfort, comfortPlus, business].map(TariffCellViewModel.init)
        section += viewModels.map(CollectionItem<TariffCell>.init)
        director.sections = [section]
        director.reload()
    }
}
