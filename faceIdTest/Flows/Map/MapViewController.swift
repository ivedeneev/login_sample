//
//  MapViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import UIKit
import RxSwift
import MapKit
import CoreLocation

final class MapViewController: BaseViewController {
    
    var viewModel: MapViewModelProtocol!
    
    lazy var mapView = MKMapView()
    lazy var locationManager = CLLocationManager()
    lazy var rideOptions = RideOptionsController()
    lazy var currentLocationLabel = UILabel()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var director = CollectionDirector(collectionView: collectionView)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        let section = CollectionSection()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        
        let addresses = [
            Address(name: "Дом", lat: 37, lon: 55),
            Address(name: "Работа", lat: 37, lon: 55),
            Address(name: "Коктейльная", lat: 37, lon: 55)
        ]
        
        addresses.forEach { (add) in
            section += CollectionItem<FavoriteDestinationCell>(item: add)
                .onSelect { [weak self] _ in
                    self?.viewModel?.selectToDestinationFromFavorites.onNext(add)
                }
        }
        
        director += section
        director.reload()
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        currentLocationLabel.backgroundColor = Color.lightBlueGray()
        currentLocationLabel.numberOfLines = 2
        currentLocationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(currentLocationLabel)
        
        let profileBtn = UIBarButtonItem(image: UIImage(named: "profile"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = profileBtn
        
        profileBtn.rx.tap
            .bind(to: viewModel.showProfile)
            .disposed(by: disposeBag)
        
        setupInfoPopup()
        
        viewModel.didSelectFavorite
            .subscribe(onNext: { [weak self] (from, to) in
                self?.rideOptions.toggle()
            })
            .disposed(by: disposeBag)
        
        viewModel.didSelectFavorite
            .bind(to: rideOptions.pointsView.rx.points)
            .disposed(by: disposeBag)
        
        rideOptions.paymentMethodButton.rx.tap
            .bind(to: viewModel.showPaymentMethods)
            .disposed(by: disposeBag)
        
        viewModel.paymentMethod
            .asDriver()
            .drive(rideOptions.paymentMethodButton.rx.paymentMethod)
            .disposed(by: disposeBag)
    }
    
    func setupInfoPopup() {
        addChild(rideOptions)
        view.addSubview(rideOptions.view)
        rideOptions.didMove(toParent: self)
        rideOptions.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rideOptions.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rideOptions.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rideOptions.view.heightAnchor.constraint(equalToConstant: rideOptions.minHeight),
            rideOptions.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

private extension Reactive where Base: UIButton {
    var paymentMethod: Binder<PaymentMethod> {
        Binder(self.base, binding: { button, paymentMethod in
            button.setTitle(paymentMethod.name, for: .normal)
            button.setImage(UIImage(named: paymentMethod.icon), for: .normal)
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.isZoomEnabled = true
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        defer {
            manager.stopUpdatingLocation()
        }
        
        guard let location = locations.first else { return }
                let regionRadius: CLLocationDistance = 2500
                let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
                mapView.setRegion(coordinateRegion, animated: false)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated", mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocationLabel.center = mapView.center
        currentLocationLabel.frame.size = CGSize(width: 40, height: 40)
                
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geocoder.reverseGeocodeLocation(loc, preferredLocale: .init(identifier: "ru_RU")) { [weak self] (placemarks, error) in
            guard let mark = placemarks?.first?.name else {
                return
            }
            
            self?.navigationItem.title = mark
            
            self?.rideOptions.pointsView.fromTextField.text = mark
        }
    }
}




class Marker: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.coordinate = coordinate

    super.init()
  }

  var subtitle: String? {
    return "fdfd"
  }
}

