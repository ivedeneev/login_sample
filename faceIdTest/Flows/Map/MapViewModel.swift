//
//  MapViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay

protocol MapViewModelProtocol {
    
    /// текущая локация пользователя выбраннная с помощью карты
    var pickupLocation: AnyObserver<CLLocationCoordinate2D> { get }
    
    /// reverse geocoded location
    var humanReadableLocation: Observable<String> { get }  // relay?
    
//    var favoritePlaces: Observable<[Address]> { get }
    
    var selectToDestinationFromFavorites: AnyObserver<Address> { get }
    var didSelectFavorite: Observable<(Address, Address)> { get }
    
    var configureRoute: Observable<(Address, Address?)> { get }
    
    var routeCoordinates: AnyObserver<(CLLocationCoordinate2D, CLLocationCoordinate2D)> { get }
    
    var showProfile: AnyObserver<Void> { get }
    var didShowProfile: Observable<Void> { get }
    
    var showPaymentMethods: AnyObserver<Void> { get }
    var didShowPaymentMethods: Observable<Void> { get }
    
    var paymentMethod: BehaviorRelay<PaymentMethod> { get }
}

final class MapViewModel: MapViewModelProtocol {
    var pickupLocation: AnyObserver<CLLocationCoordinate2D>
    
    var humanReadableLocation: Observable<String>
    
    var routeCoordinates: AnyObserver<(CLLocationCoordinate2D, CLLocationCoordinate2D)>
    
    var showProfile: AnyObserver<Void>
    var didShowProfile: Observable<Void>
    
    var selectToDestinationFromFavorites: AnyObserver<Address>
    var didSelectFavorite: Observable<(Address, Address)>
    
    var configureRoute: Observable<(Address, Address?)>
    
    var showPaymentMethods: AnyObserver<Void>
    var didShowPaymentMethods: Observable<Void>
    
    var paymentMethod: BehaviorRelay<PaymentMethod>
    
    private var currentLocation = BehaviorRelay<Address?>(value: Address(name: "Дом", lat: 37, lon: 55))
    private let disposeBag = DisposeBag()
    
    init() {
        pickupLocation = .init(eventHandler: { (_) in
            
        })
        
        routeCoordinates = .init(eventHandler: { (_) in
            
        })
        
        humanReadableLocation = .empty()
        
        let _profile = PublishSubject<Void>()
        showProfile = _profile.asObserver()
        didShowProfile = _profile.asObservable()
        
        let _selectFavorite = PublishSubject<Address>()
        selectToDestinationFromFavorites = _selectFavorite.asObserver()
        didSelectFavorite = _selectFavorite
            .withLatestFrom(
                currentLocation.asObservable(),
                resultSelector: { to, from -> (Address, Address) in
                    return (from!, to)
                }
            )
        
        let _selectRidePoints = PublishSubject<(Address, Address?)>()
        configureRoute = _selectRidePoints.asObservable()
        
        let _showPayment = PublishSubject<Void>()
        showPaymentMethods = _showPayment.asObserver()
        didShowPaymentMethods = _showPayment.asObservable()
        
        paymentMethod = .init(value: .applePay)
        
//        _selectFavorite
//            .withLatestFrom(
//                currentLocation.asObservable(),
//                resultSelector: { to, from -> (Address, Address?) in
//                    return (from!, to)
//                }
//            )
//            .bind(to: _selectRidePoints.asObserver()) // показывать уже расчитаную поездку; Если нажали на поиск - показывать экран
//            .disposed(by: disposeBag)
    }
}
