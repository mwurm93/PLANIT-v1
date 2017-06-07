//
//  ViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/6/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Apollo
import Firebase

class PasswordViewController: UIViewController, UITextFieldDelegate {

    // *** Add code to update whether existingUser = true
    var existingUser = false

    // MARK: Outlets
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var createPasswordLabel: UILabel!
    @IBOutlet weak var enterPasswordLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.Password.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        Password.becomeFirstResponder()
        Password.layer.borderWidth = 1
        Password.layer.cornerRadius = 5
        Password.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        Password.layer.masksToBounds = true
        let passwordLabelPlaceholder = Password!.value(forKey: "placeholderLabel") as? UILabel
        passwordLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        createPasswordLabel.isHidden = true
        enterPasswordLabel.isHidden = true
        
        apollo.fetch(query: GetAllUsersQuery(where: UserWhereArgs(username: UserUsernameWhereArgs(eq: DataContainerSingleton.sharedDataContainer.emailAddress)))) { (result, error) in
            guard let data = result?.data else { return }
            
            let matchingUsersCount = data.viewer?.allUsers?.edges?.count
            if matchingUsersCount == 1 {
                self.existingUser = true
            }
            if self.existingUser == true {
                self.enterPasswordLabel.isHidden = false
            }
            else {
                self.createPasswordLabel.isHidden = false
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate for firstName
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        Password.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        DataContainerSingleton.sharedDataContainer.password = Password.text
        
        if (Password.text?.characters.count)! >= 6 {
            if existingUser == false {
            
            //Create account and authenticate instance
            apollo.perform(mutation: CreateUserMutation(user: CreateUserInput(password: DataContainerSingleton.sharedDataContainer.password!, username: DataContainerSingleton.sharedDataContainer.emailAddress!)), resultHandler: { (result, error) in
                guard let data = result?.data else { return }
                let token = data.createUser?.token
                
//                //Authenticate
//                apollo = {
//                    let configuration = URLSessionConfiguration.default
//                    // Add additional headers as needed
//                    configuration.httpAdditionalHeaders = ["Authorization": "Bearer <\(token)>"]
//                    
//                    let url = URL(string: "https://us-west-2.api.scaphold.io/graphql/deserted-salt")!
//                    
//                    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
//                }()
                
                //Save token to singleton
                DataContainerSingleton.sharedDataContainer.token = token
                
                //resign first responder and seque
                self.Password.resignFirstResponder()
                super.performSegue(withIdentifier: "passwordToTripList", sender: self)
                
            })
            } else if existingUser == true {
                
                apollo.perform(mutation: LoginUserMutation(user: LoginUserInput(username: DataContainerSingleton.sharedDataContainer.emailAddress!, password: DataContainerSingleton.sharedDataContainer.password!)), resultHandler: { (result, error) in
                    
                    guard let data = result?.data else { return }
                    
                    var token: String?
                    if data.loginUser?.token != nil {
                        token = data.loginUser?.token
                    }
                    
                    if token == nil {
                        UIView.animate(withDuration: 0.5) {
                            self.createPasswordLabel.text = "Invalid password, please try again"
                            self.enterPasswordLabel.text = "Invalid password, please try again"
                            self.Password.becomeFirstResponder()
                        }
                        return
                    } else {
                        
//                        //Authenticate
//                        apollo = {
//                            let configuration = URLSessionConfiguration.default
//                            // Add additional headers as needed
//                            configuration.httpAdditionalHeaders = ["Authorization": "Bearer <\(token)>"]
//                            
//                            let url = URL(string: "https://us-west-2.api.scaphold.io/graphql/deserted-salt")!
//                            
//                            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
//                        }()
//
                        //Save token to singleton
                        DataContainerSingleton.sharedDataContainer.token = token
                        
                        //resign first responder and seque
                        self.Password.resignFirstResponder()
                        super.performSegue(withIdentifier: "passwordToTripList", sender: self)
                    }
                })
            }
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.createPasswordLabel.text = "Your password must be longer than 6 characters"
                self.enterPasswordLabel.text = "Your password must be longer than 6 characters"
                self.Password.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in // 2
            if let err = error { // 3
                print(err.localizedDescription)
                return
            }
            
        })

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.4) {
            self.Password.frame.origin.y = 408
            self.enterPasswordLabel.frame.origin.y = 363
            self.createPasswordLabel.frame.origin.y = 363
        }
        
        return true
    }
}
