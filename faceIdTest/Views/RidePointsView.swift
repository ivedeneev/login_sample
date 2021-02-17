//
//  RidePointsView.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit
import RxSwift

final class RidePointsView: UIView {
    
    let fromTextField = UITextField()
    let toTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(fromTextField)
        fromTextField.placeholder = "Откуда"
        fromTextField.translatesAutoresizingMaskIntoConstraints = false
        fromTextField.backgroundColor = Color.background()
        fromTextField.clearButtonMode = .whileEditing

        addSubview(toTextField)
        toTextField.placeholder = "Куда"
        toTextField.translatesAutoresizingMaskIntoConstraints = false
        toTextField.backgroundColor = Color.background()
        toTextField.clearButtonMode = .whileEditing
        
        let pointsImageView = UIImageView()
        pointsImageView.image = UIImage(named: "ride_points")
        pointsImageView.contentMode = .scaleAspectFill
        pointsImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pointsImageView)
        
        NSLayoutConstraint.activate([
            pointsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pointsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            pointsImageView.widthAnchor.constraint(equalToConstant: 13),
            pointsImageView.heightAnchor.constraint(equalToConstant: 61),
             
            fromTextField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            fromTextField.leadingAnchor.constraint(equalTo: pointsImageView.trailingAnchor, constant: 16),
            fromTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fromTextField.heightAnchor.constraint(equalToConstant: 44),
            
            toTextField.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 2),
            toTextField.leadingAnchor.constraint(equalTo: fromTextField.leadingAnchor),
            toTextField.trailingAnchor.constraint(equalTo: fromTextField.trailingAnchor),
            toTextField.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

extension Reactive where Base: RidePointsView {
    var points: Binder<(Address, Address)> {
        Binder(self.base) { (base, points) in
            base.fromTextField.text = points.0.name
            base.toTextField.text = points.1.name
        }
    }
}
