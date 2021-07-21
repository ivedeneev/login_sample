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
//                let vc = PopupController<PaymentMethodsController>()
//                vc.content.roundCorners()
//                vc.preferredContentSize = CGSize(width: self!.view.bounds.width, height: 350)
                self?.present(
                    TranslucentNavigationController(
                        rootViewController: AddCardViewController()
                    ),
                    animated: true,
                    completion: nil
                )
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

class AddCardViewController: BaseViewController {
    
    private let cardTextField = CardTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardTextField.becomeFirstResponder()
    }
    
    private func setup() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 84),
        ])
        
        let helloLabel = UILabel()
        helloLabel.text = L10n.AddCard.title
        helloLabel.font = Font.largeTitle
//        helloLabel.textAlignment = .center
        helloLabel.textColor = Color.text()
        
        stackView.addArrangedSubview(helloLabel)
        
        cardTextField.placeholder = "Card number"
        let scanButton = UIButton()
        scanButton.setImage(Asset.faceId, for: .normal)
        cardTextField.rightView = scanButton
        cardTextField.rightViewMode = .always
        cardTextField.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        
//        cardTextField.backgroundColor = Color.secondaryBackground()
        cardTextField.clipsToBounds = true
        cardTextField.layer.cornerRadius = 8
        cardTextField.tintColor = Color.accent()
        stackView.addArrangedSubview(cardTextField)
        
        
        let st2 = UIStackView()
//        st2.translatesAutoresizingMaskIntoConstraints = false
        st2.alignment = .fill
        st2.distribution = .fillEqually
        st2.axis = .horizontal
        st2.spacing = 16
        
        let expirationDateField = FloatingLabelTextField()
        let cvvField = FloatingLabelTextField()
        expirationDateField.placeholder = "Expires"
        cvvField.placeholder = "CVV"
        st2.addArrangedSubview(expirationDateField)
        st2.addArrangedSubview(cvvField)
        stackView.addArrangedSubview(st2)
        
        let addButton = CommonButton()
        addButton.backgroundColor = Color.accent()
        addButton.setTitle(L10n.AddCard.add, for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        
        let close = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        navigationItem.leftBarButtonItem = close
    }
}

class CardTextField: FloatingLabelTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        keyboardType = .decimalPad
        textContentType = .creditCardNumber
        addTarget(self, action: #selector(didChangeEditing), for: .editingChanged)
    }
    
    @objc private func didChangeEditing() {
//        if let delegate = formattingDelegate {
//            text = delegate.formatPhoneNumber(for: self)
//            return
//        }
//
        guard var t = text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        text = t.formattedNumber(mask: "XXXX XXXX XXXX XXXX")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 56)
    }
}
