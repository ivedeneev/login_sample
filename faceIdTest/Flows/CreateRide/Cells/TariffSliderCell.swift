//
//  TariffSliderCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import IVCollectionKit

final class TariffSliderCell: UICollectionViewCell {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var director = CollectionDirector(collectionView: collectionView)
    private let section = CollectionSection()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.frame = frame
        collectionView.showsHorizontalScrollIndicator = false
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TariffSliderCell: ConfigurableCollectionItem {
    static func estimatedSize(item: Void, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: boundingSize.width, height: 90)
    }
    
    func configure(item: ()) {
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
