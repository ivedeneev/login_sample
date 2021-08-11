//
//  GeocodedLocationProvider.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 23.07.2021.
//

import Foundation
import RxSwift
import CoreLocation

protocol GeocodedLocationProvider {
    func geocoded(loc: CLLocationCoordinate2D) -> Observable<CLPlacemark?>
}

final class GeocodedLocationProviderImpl: GeocodedLocationProvider {
    func geocoded(loc: CLLocationCoordinate2D) -> Observable<CLPlacemark?> {
        Observable.create { observer in
            let geocoder = CLGeocoder()
            let loc = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            let locale = Locale(identifier: "ru_RU")
            
            geocoder.reverseGeocodeLocation(loc, preferredLocale: locale) { (placemarks, error) in
                observer.onNext(placemarks?.first)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
}
