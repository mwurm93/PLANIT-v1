//
//  ObjCAccessoryMethods.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/20/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

@objc class ObjCAccessoryMethods: NSObject {
    func getTripViewController(viewController:UIViewController) -> TripViewController {
        return viewController as! TripViewController
    }
}
