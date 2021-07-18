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
        
    }
    
    private func setup() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.alignment = .center
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
        helloLabel.font = Font.title
        helloLabel.textAlignment = .center
        helloLabel.textColor = Color.text()
        
        stackView.addArrangedSubview(helloLabel)
        
        cardTextField.placeholder = "____ ____ ____ ____"
        let scanButton = UIButton()
        scanButton.setImage(UIImage(named: "faceId"), for: .normal)
        cardTextField.rightView = scanButton
        cardTextField.rightViewMode = .always
        cardTextField.font = .monospacedDigitSystemFont(ofSize: 24, weight: .light)
        
        cardTextField.backgroundColor = Color.secondaryBackground()
        cardTextField.clipsToBounds = true
        cardTextField.layer.cornerRadius = 8
        stackView.addArrangedSubview(cardTextField)
        
        let addButton = CommonButton()
        addButton.backgroundColor = Color.accent()
        addButton.setTitle("Добавить", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let close = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        navigationItem.leftBarButtonItem = close
    }
}

class CardTextField: UITextField {
    
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
//
//        switch t.first {
//        case "8":
//            t = "+7" + t.dropFirst()
//        case "9":
//            t = "+7" + t
//        default:
//            break
//        }
//
//        if t.count > 1, t.first != "+" || String(Array(t)[1]) != "7" && t.first == "+" {
//            t.insert(contentsOf: "+7", at: .init(utf16Offset: 0, in: t))
//        }
        
        text = t.formattedNumber(mask: "XXXX XXXX XXXX XXXX")
    }
    
    struct Constants {
        static let sidePadding: CGFloat = 16
        static let topPadding: CGFloat = 8
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + Constants.sidePadding,
            y: bounds.origin.y + Constants.topPadding,
            width: bounds.size.width - Constants.sidePadding * 2,
            height: bounds.size.height - Constants.topPadding * 2
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 56)
    }
}
