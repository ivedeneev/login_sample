//
//  Observable+Extension.swift
//  LoginSample
//
//  Created by Igor Vedeneev on 27.04.2021.
//

import Foundation
import RxSwift

extension Observable {
    func mapToVoid() -> Observable<Void> {
        mapTo(Void())
    }
}
