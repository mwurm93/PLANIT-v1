//
//  RightViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 8/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class RightViewController: UIViewController {

    //MARK: Class vars
    
    //MARK: Outlets
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.view.endEditing(true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        
        
    }

}
