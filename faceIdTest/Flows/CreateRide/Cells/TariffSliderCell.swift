//
//  TariffSliderCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit

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
        CGSize(width: boundingSize.width, height: 120)
    }
    
    func configure(item: ()) {
        section.removeAll()
        section += [CollectionItem<TariffCell>(item: ()), CollectionItem<TariffCell>(item: ()), CollectionItem<TariffCell>(item: ())]
        director.sections = [section]
        director.reload()
    }
}
