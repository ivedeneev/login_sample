//
//  Protocols.swift
//  CollectionKit
//
//  Created by Igor Vedeneev on 27/08/2018.
//  Copyright © 2018 Igor Vedeneev. All rights reserved.
//

import UIKit

//MARK:- ConfigurableCollectionItem
public protocol ConfigurableCollectionItem : Reusable {
    associatedtype T
    static func estimatedSize(item: T, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize
    func configure(item: T)
}


//MARK:- AbstractCollectionItem
public protocol AbstractCollectionItem : AbstractCollectionReusableView {
    var reuseIdentifier: String { get }
    var identifier: String { get }
    var cellType: AnyClass { get }
    var adjustsWidth: Bool { get set }
    var adjustsHeight: Bool { get set }
    
    var onSelect: ((_ indexPath: IndexPath) -> Void)? { get set }
    var onDeselect: ((_ indexPath: IndexPath) -> Void)? { get set }
    var onDisplay: ((_ indexPath: IndexPath, _ cell: UICollectionViewCell) -> Void)? { get set }
    var onEndDisplay: ((_ indexPath: IndexPath, _ cell: UICollectionViewCell) -> Void)? { get set }
    var onHighlight: ((_ indexPath: IndexPath) -> Void)? { get set }
    var onUnighlight: ((_ indexPath: IndexPath) -> Void)? { get set }
    var shouldHighlight: Bool { get set }
    var shouldSelect: Bool { get set }
    var shouldDeselect: Bool { get set }
    
    func configure(_: UICollectionReusableView)
    func estimatedSize(boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize
}


//MARK:- AbstractCollectionReusableView
public protocol AbstractCollectionReusableView {
    var reuseIdentifier: String { get }
    var identifier: String { get }
    func configure(_: UICollectionReusableView)
    func estimatedSize(boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize
}


//MARK:- AbstractCollectionHeaderFooterItem
public protocol AbstractCollectionHeaderFooterItem : AbstractCollectionReusableView {
    var reuseIdentifier: String { get }
    var identifier: String { get }
    var viewType: AnyClass { get }
    var onDisplay: (() -> Void)? { get set }
    var onEndDisplay: (() -> Void)? { get set }
    func configure(_: UICollectionReusableView)
    func estimatedSize(boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize
}
