//
//  hideKeyboardWhenTappedAround.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let hideKeyboardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(hideKeyboardTap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
