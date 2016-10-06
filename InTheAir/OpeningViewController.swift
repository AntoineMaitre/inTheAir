//
//  openingViewController.swift
//  InTheAir
//
//  Created by Alexandre VLADOVICH on 06/10/16.
//  Copyright © 2016 AlexandreVlado. All rights reserved.
//

import UIKit

class OpeningViewController : UIViewController {
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        mapButton.layer.borderWidth = 3.0
        mapButton.layer.borderColor = UIColor.white.cgColor
        mapButton.layer.cornerRadius = 5.0
    }
    
    override func viewDidLoad() {
        UIView.animate(withDuration: 2.0) { 
            self.titleLabel.alpha = 1.0
            UIView.animate(withDuration: 2.0, animations: { 
                self.mapButton.alpha = 1.0
            })
        }
    }
}
