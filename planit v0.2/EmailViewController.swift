//
//  SignUpViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/10/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var pleaseEnterEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddress.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        emailAddress.becomeFirstResponder()
        emailAddress.setBottomBorder(borderColor: UIColor.white)

//        emailAddress.layer.borderWidth = 1
//        emailAddress.layer.cornerRadius = 5
//        emailAddress.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        emailAddress.layer.masksToBounds = true
        let emailAddressLabelPlaceholder = emailAddress!.value(forKey: "placeholderLabel") as? UILabel
        emailAddressLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
//        let clearButton = emailAddress?.value(forKey: "clearButton") as! UIButton
//        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
//        clearButton.tintColor = UIColor.white
//        clearButton.alpha = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Load the values from our shared data container singleton
        let emailAddressValue = DataContainerSingleton.sharedDataContainer.emailAddress ?? ""
        
        //Install the value into the text field.
        self.emailAddress.text =  "\(emailAddressValue)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.4) {
            self.emailAddress.frame.origin.y = 408
            self.pleaseEnterEmail.frame.origin.y = 372
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        if (emailAddress.text?.contains("@"))! {
            emailAddress.resignFirstResponder()
            super.performSegue(withIdentifier: "emailToPassword", sender: self)
        } else {
            UIView.animate(withDuration: 0.5) {
                self.pleaseEnterEmail.text = "Please enter a valid email address"
                self.emailAddress.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func EmailFieldEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.emailAddress = emailAddress.text
        
    }
    
}
