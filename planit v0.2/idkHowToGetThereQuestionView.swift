//
//  idkHowToGetThereQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/24/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
//import SafariServices

class idkHowToGetThereQuestionView: UIView {
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var linkLabel1: UIButton?
    var linkLabel2: UIButton?
//    var linkLabel3: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 140)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 330
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2

        linkLabel1?.sizeToFit()
        linkLabel1?.frame.size.height = 30
        linkLabel1?.frame.size.width += 20
        linkLabel1?.frame.origin.x = (bounds.size.width - (linkLabel1?.frame.width)!) / 2
        linkLabel1?.frame.origin.y = 210
        linkLabel1?.layer.cornerRadius = (linkLabel1?.frame.height)! / 2


        linkLabel2?.sizeToFit()
        linkLabel2?.frame.size.height = 30
        linkLabel2?.frame.size.width += 20
        linkLabel2?.frame.origin.x = (bounds.size.width - (linkLabel2?.frame.width)!) / 2
        linkLabel2?.frame.origin.y = 260
        linkLabel2?.layer.cornerRadius = (linkLabel2?.frame.height)! / 2

        
//        linkLabel3?.sizeToFit()
//        linkLabel3?.frame.size.height = 30
//        linkLabel3?.frame.size.width += 20
//        linkLabel3?.frame.origin.x = (bounds.size.width - (linkLabel1?.frame.width)!) / 2
//        linkLabel3?.frame.origin.y = 310

    }
    
    
    func addViews() {
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Check out these resources!"
        self.addSubview(questionLabel!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("I'm ready to plan travel", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)

        //Link1
        linkLabel1 = UIButton(type: .custom)
        linkLabel1?.frame = CGRect.zero
        linkLabel1?.setTitleColor(UIColor.white, for: .normal)
        linkLabel1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        linkLabel1?.layer.borderWidth = 1
        linkLabel1?.layer.borderColor = UIColor.white.cgColor
        linkLabel1?.layer.masksToBounds = true
        linkLabel1?.titleLabel?.numberOfLines = 0
        linkLabel1?.titleLabel?.textAlignment = .center
        linkLabel1?.setTitle("Open Rome2Rio", for: .normal)
        linkLabel1?.translatesAutoresizingMaskIntoConstraints = false
        linkLabel1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(linkLabel1!)

        //Link2
        linkLabel2 = UIButton(type: .custom)
        linkLabel2?.frame = CGRect.zero
        linkLabel2?.setTitleColor(UIColor.white, for: .normal)
        linkLabel2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        linkLabel2?.layer.borderWidth = 1
        linkLabel2?.layer.borderColor = UIColor.white.cgColor
        linkLabel2?.layer.masksToBounds = true
        linkLabel2?.titleLabel?.numberOfLines = 0
        linkLabel2?.titleLabel?.textAlignment = .center
        linkLabel2?.setTitle("Open Google Maps", for: .normal)
        linkLabel2?.translatesAutoresizingMaskIntoConstraints = false
        linkLabel2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(linkLabel2!)
//        //Link3
//        linkLabel3 = UIButton(type: .custom)
//        linkLabel3?.frame = CGRect.zero
//        linkLabel3?.setTitleColor(UIColor.white, for: .normal)
//        linkLabel3?.setBackgroundColor(color: UIColor.clear, forState: .normal)
//        linkLabel3?.setTitleColor(UIColor.lightGray, for: .highlighted)
//        linkLabel3?.layer.masksToBounds = true
//        linkLabel3?.titleLabel?.numberOfLines = 0
//        linkLabel3?.titleLabel?.textAlignment = .center
//        linkLabel3?.setTitle("Rome2Rio", for: .normal)
//        linkLabel3?.setTitle("Rome2Rio", for: .selected)
//        linkLabel3?.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(linkLabel3!)
//        
        
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender, color: UIColor.white)
        }
    
        if sender == linkLabel1 {
            let rome2RioURLString = "https://www.rome2rio.com"
            let rome2RioURL = URL(string: rome2RioURLString)
            
            if UIApplication.shared.canOpenURL(rome2RioURL!) {
                //open Rome2rio app
                UIApplication.shared.open(rome2RioURL!)
            } else {
                //redirect to safari VC because the user doesn't have Rome2Rio
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openRome2RioSFSafariViewer"), object: nil)
            }
        } else if sender == linkLabel2 {
            let googleMapsURLString = "comgooglemaps://"
            let googleMapsURL = URL(string: googleMapsURLString)
            
            if UIApplication.shared.canOpenURL(googleMapsURL!) {
                //open  app
                UIApplication.shared.open(googleMapsURL!)
            } else {
                //redirect to safari VC because the user doesn't have app
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openGoogleMapsSFSafariViewer"), object: nil)
            }
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton, color: UIColor.white)
            }
        }
    }
}

////MARK: SFSafariViewControllerDelegate
//extension idkHowToGetThereQuestionView: SFSafariViewControllerDelegate {
//    func showWebsite(URL: URL) {
//        let webVC = SFSafariViewController(url: URL)
//        webVC.delegate = self
//        webVC.preferredBarTintColor = UIColor(red: 25/255, green: 134/255, blue: 191/255, alpha: 1)
//        webVC.preferredControlTintColor = UIColor.white
//        self.present(webVC, animated: true, completion: nil)
//    }
//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//}

