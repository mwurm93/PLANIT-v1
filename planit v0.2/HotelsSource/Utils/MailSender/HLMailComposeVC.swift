//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  HLMailComposeVC.swift
//  HotelLook
//
//  Created by Anton Chebotov on 23/04/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

import MessageUI

class HLMailComposeVC: MFMailComposeViewController {
    override func viewWillAppear(_ animated: Bool) {
        parentViewController?.resignFirstResponder()
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}