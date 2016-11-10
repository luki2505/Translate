//
//  Extensions.swift
//  Translate
//
//  Created by Lukas on 25.10.16.
//  Copyright © 2016 WIT. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
