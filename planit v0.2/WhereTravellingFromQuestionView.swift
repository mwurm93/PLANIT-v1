//
//  WhereTravellingFromQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces

class WhereTravellingFromQuestionView: UIView, UISearchControllerDelegate, UISearchBarDelegate {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
        //GOOGLE PLACES SEARCH
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var subView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
//        self.layer.borderColor = UIColor.blue.cgColor
//        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 190
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        if DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
            button1?.isHidden = false
        } else {
            button1?.isHidden = true
        }
        
        subView?.frame = CGRect(x: (bounds.size.width-275)/2, y: 120, width: 275, height: 30)
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
        questionLabel?.text = "Where will you be coming from?"
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
        button1?.setTitle("Yep, that's right", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)

        
        //GOOGLE PLACES SEARCH
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.tableCellBackgroundColor = UIColor.darkGray
        resultsViewController?.tableCellSeparatorColor = UIColor.lightGray
        resultsViewController?.primaryTextColor = UIColor.lightGray
        resultsViewController?.secondaryTextColor = UIColor.lightGray
        resultsViewController?.primaryTextHighlightColor = UIColor.white
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.isTranslucent = true
        searchController?.searchBar.layer.cornerRadius = 5
        searchController?.searchBar.barStyle = .default
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.setShowsCancelButton(false, animated: false)
        searchController?.searchBar.delegate = self
        let attributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 14)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
        subView = UIView(frame: CGRect(x: (bounds.size.width-275)/2, y: 120, width: 275, height: 30))
        subView?.addSubview((searchController?.searchBar)!)
        self.addSubview(subView!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        //        definesPresentationContext = true
        if DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
            searchController?.searchBar.text = DataContainerSingleton.sharedDataContainer.homeAirport
        }        
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton)
            }
        }
    }
    
}
// Handle the user's selection GOOGLE PLACES SEARCH
extension WhereTravellingFromQuestionView: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
        searchController?.searchBar.text = place.name
        DataContainerSingleton.sharedDataContainer.homeAirport = searchController?.searchBar.text
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "whereTravellingFromEntered"), object: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
