//
//  ConfigureRideController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit
import RxSwift
import RxRelay

final class ConfigureRideController: CollectionViewController {
    var viewModel: ConfigureRideViewModelProtocol!
    
    lazy var pointsView = RidePointsView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pointsView)
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pointsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pointsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            pointsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pointsView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        viewModel.toPointRelay
            .asDriver()
            .map { $0?.name }
            .drive(pointsView.toTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.fromPointRelay
            .asDriver()
            .map { $0?.name }
            .drive(pointsView.fromTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

protocol ConfigureRideViewModelProtocol {
    var fromPointRelay: BehaviorRelay<Address?> { get }
    var toPointRelay: BehaviorRelay<Address?> { get }
}

final class ConfigureRideViewModel: ConfigureRideViewModelProtocol {
    
    let fromPointRelay: BehaviorRelay<Address?>
    let toPointRelay: BehaviorRelay<Address?>
    
    init(fromAddress: Address, toAddress: Address?) {
        toPointRelay = .init(value: toAddress)
        fromPointRelay = .init(value: fromAddress)
    }
}

final class ConfigureRideCoordinator: BaseCoordinator<Void> {
    
    private let startPoint: Address
    private let endPoint: Address?
    
    init(startPoint: Address, endPoint: Address?, rootVc: UIViewController?) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        super.init()
        rootViewController = rootVc
    }
    
    override func start() -> Observable<Void> {
        let vc = ConfigureRideController()
        let vm = ConfigureRideViewModel(fromAddress: startPoint, toAddress: endPoint)
        vc.viewModel = vm
        
        rootViewController?.present(vc, animated: true, completion: nil)
        
        return .never()
    }
}
