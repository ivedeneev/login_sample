//
//  PinCodeController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 13.02.2021.
//

import UIKit
import RxSwift
import RxRelay
import LocalAuthentication

enum PinCodeType {
    case create
    case confirm
}

final class PinCodeController: BaseViewController {
    
    lazy var keyboardDigits: [PinPadItem] = {
        [1,2,3,4,5,6,7,8,9,0].map(PinPadItem.itemWithDigit)
    }()
    
    lazy var deleteOrFaceIdButton = UIButton()
    lazy var forgotPasswordButton = UIButton()
    
    private lazy var codeField = CodeTextField()
    private let codeRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        setupPinPad()
        setupDots()
    }
    
    private func setupDots() {
        
    }
    
    func setupPinPad() {
        let line1 = UIStackView()
        line1.addArrangedSubview(keyboardDigits[0])
        line1.addArrangedSubview(keyboardDigits[1])
        line1.addArrangedSubview(keyboardDigits[2])
        line1.spacing = 8
        line1.distribution = .equalCentering
        
        let line2 = UIStackView()
        line2.addArrangedSubview(keyboardDigits[3])
        line2.addArrangedSubview(keyboardDigits[4])
        line2.addArrangedSubview(keyboardDigits[5])
        line2.spacing = 8
        line2.distribution = .equalCentering
        
        let line3 = UIStackView()
        line3.addArrangedSubview(keyboardDigits[6])
        line3.addArrangedSubview(keyboardDigits[7])
        line3.addArrangedSubview(keyboardDigits[8])
        line3.spacing = 8
        line3.distribution = .equalCentering
        
        let line4 = UIStackView()
        let dummyItem = PinPadItem()
        dummyItem.backgroundColor = .clear
        line4.addArrangedSubview(dummyItem)
        line4.addArrangedSubview(keyboardDigits[9])
        line4.addArrangedSubview(deleteOrFaceIdButton)
        line4.spacing = 8
        line4.distribution = .equalCentering
        
        let stack = UIStackView()
        stack.spacing = 12
        stack.axis = .vertical
        
        stack.addArrangedSubview(line1)
        stack.addArrangedSubview(line2)
        stack.addArrangedSubview(line3)
        stack.addArrangedSubview(line4)
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        ])
        
        let digitSignals = keyboardDigits.map {
            $0.rx.controlEvent(.touchUpInside)
                .mapTo($0.digit)
                .compactMap { $0 }
                .map(String.init)
        }
        
        // поток ввода цифр
        let digitTapObservable = Observable.merge(digitSignals).withLatestFrom(codeRelay) { (digit, code) -> String in
            code.count < 4 ? code.appending(digit) : code
        }
        
        // поток нажатий на нижнюю правую кнопку
        let rightButtonTap = deleteOrFaceIdButton.rx.tap.share().withLatestFrom(codeRelay)
        
        // если заполнен хотя бы 1 символ - кнопка работает как delete; если еще ничего не заполнено - даем возможность воспользоваться FaceID, если он разрешен
        let deleteTap = rightButtonTap.filter { !$0.isEmpty }
        let applyFaceID = rightButtonTap.filter { $0.isEmpty }
        
        // удаление последней цифры
        let deleteObservable = deleteTap.map { code in String(code.dropLast()) }
        
        deleteObservable
            .merge(with: digitTapObservable)
            .bind(to: codeRelay)
            .disposed(by: disposeBag)
        
        // икнока для правой нижней кнопки (FaceID или удаление последнего символа)
        codeRelay
            .map { $0.isEmpty ? UIImage(named: "faceId") : UIImage(named: "keypad_delete") }
            .bind(to: deleteOrFaceIdButton.rx.image())
            .disposed(by: disposeBag)
        
        codeRelay.asObservable().debug().subscribe().disposed(by: disposeBag)
        
        deleteOrFaceIdButton.backgroundColor = .clear
        deleteOrFaceIdButton.tintColor = Color.green()
        deleteOrFaceIdButton.setImage(UIImage(named: "faceId"), for: .normal)// = UIImage(named: "faceId")
    }
}

final class PinPadItem: UIControl {
    
    var icon: UIImage? {
        didSet {
//            digitLabel.isHidden = true
//            iconImageView.isHidden = false
            iconImageView.image = icon
        }
    }
    
    var digit: Int? {
        didSet {
            guard let d = digit else { return }
//            digitLabel.isHidden = false
//            iconImageView.isHidden = true
            digitLabel.text = d.description
        }
    }
    
    private let digitLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 60, height: 60)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.lightGreen()
//        clipsToBounds = true
//        layer.cornerRadius = 30
        
        digitLabel.textColor = UIColor.white
        digitLabel.textAlignment = .center
        digitLabel.font = .systemFont(ofSize: 24, weight: .medium)
        
        addSubview(digitLabel)
        addSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        digitLabel.frame = bounds
        iconImageView.frame = bounds
    }
    
    class func itemWithDigit(_ digit: Int) -> PinPadItem {
        let item = PinPadItem()
        item.digit = digit
        return item
    }
    
    class func itemWithIcon(_ icon: UIImage?) -> PinPadItem {
        let item = PinPadItem()
        item.icon = icon
        return item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum EnablePinResult {
    case enabled
    case cancel
}

final class EnablePinCoordinator: BaseCoordinator<EnablePinResult> {
    
    init(root: UIViewController?) {
        super.init()
        rootViewController = root
    }
    
    override func start() -> Observable<EnablePinResult> {
        Observable.create { [rootViewController] observer in
            let ac = UIAlertController(title: "Добавить вход по коду?", message: nil, preferredStyle: .actionSheet)
            
            ac.addAction(
                .init(title: "Добавить", style: .default, handler: { _ in
                    observer.onNext(.enabled)
                    observer.onCompleted()
                }
            ))
            
            ac.addAction(
                .init(title: "Позже", style: .default, handler: { _ in
                    observer.onNext(.cancel)
                    observer.onCompleted()
                }
            ))
            
            rootViewController?.present(ac, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
}



