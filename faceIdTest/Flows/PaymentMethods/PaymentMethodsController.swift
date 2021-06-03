//
//  PaymentMethodsController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit
import RxSwift
import IVCollectionKit

final class PaymentMethodsController: CollectionViewController, PopupContentView {
    var frameInPopup: CGRect {
        let height: CGFloat = CGFloat(methods.count + 1) * 52 + 80 + 34 + 20
        return CGRect(x: 0, y: view.bounds.height - height, width: view.bounds.width, height: height)
    }
    
    var scrollView: UIScrollView? { return collectionView }
    
    let selectSubject = PublishSubject<PaymentMethod>()
    let createSubject = PublishSubject<Void>()
    
    let methods: [PaymentMethod] = [
        .card(Card(name: "Visa ** 7454", issuer: .visa)),
        .applePay,
        .cash
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = CollectionSection()
        section.insetForSection = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        section += CollectionItem<ProfileHeaderCell>(item: User(name: "Оплата", phone: "", favoriteAddresses: [], cards: []))
        section += methods.map { method in
            CollectionItem<CommonCell>(item: CommonCellViewModel(title: method.name, subtitle: nil, icon: method.icon))
                .onSelect { [weak self] _ in
                    self?.selectSubject.onNext(method)
                }
        }
        
        let addSection = CollectionSection()
        addSection.insetForSection = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        
        addSection += CollectionItem<CommonCell>(item: .init(title: "Добавить", subtitle: nil, icon: "plus"))
            .onSelect { [weak self] _ in
                let vc = PopupController<PaymentMethodsController>()
                vc.content.roundCorners()
                vc.preferredContentSize = CGSize(width: self!.view.bounds.width, height: 350)
                self?.present(vc, animated: true, completion: nil)
            }
            .onDisplay { _, cell in
                (cell as? CommonCell)?.titleLabel.textColor = Color.accent()
            }
        
        director += section
        director += addSection
        director.reload()
    }
}

enum PaymentMethodResult {
    case method(PaymentMethod)
    case dismissed
}

final class SelectPaymentMethodCoordinator: BaseCoordinator<PaymentMethodResult> {
    
    init(rootVc: UIViewController?) {
        super.init()
        rootViewController = rootVc
    }
    
    override func start() -> Observable<PaymentMethodResult> {
        let vc = PopupController<PaymentMethodsController>()
        vc.content.roundCorners()
        
        rootViewController?.present(vc, animated: true, completion: nil)
        
        return vc.content.selectSubject.map { PaymentMethodResult.method($0) }
            .merge(with: vc.rx.deallocated.map { PaymentMethodResult.dismissed })
            .take(1)
    }
}
