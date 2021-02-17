//
//  ViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 28.01.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tf = CodeTextField()
        tf.font = .monospacedDigitSystemFont(ofSize: 30, weight: .light)
        
        view.addSubview(tf)
        tf.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
//        tf.textAlignment = .center
        tf.showDashes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tf.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            tf.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            tf.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    
}

//MARK:- PhoneTextField

