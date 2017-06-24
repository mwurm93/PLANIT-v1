//
//  YesCityDecidedQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces

class YesCityDecidedQuestionView: UIView, UISearchControllerDelegate, UISearchBarDelegate {
    
    //Class vars
    var questionLabel: UILabel?
    var button: UIButton?
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
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 160)
        
        subView?.frame = CGRect(x: (bounds.size.width-275)/2, y: 200, width: 275, height: 30)
        
        button?.sizeToFit()
        button?.frame.size.height = 30
        button?.frame.size.width += 20
        button?.frame.origin.x = (bounds.size.width - (button?.frame.width)!) / 2
        button?.frame.origin.y = 260
        button?.layer.cornerRadius = (button?.frame.height)! / 2
        
    }
    
    func addViews() {
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        //        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Awesome!\n\nWhere do you want to go?"
        self.addSubview(questionLabel!)
        
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
        
        //Button
        button = UIButton(type: .custom)
        button?.frame = CGRect.zero
        button?.setTitleColor(UIColor.white, for: .normal)
        button?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button?.setTitleColor(UIColor.white, for: .selected)
        button?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        button?.layer.borderWidth = 1
        button?.layer.borderColor = UIColor.white.cgColor
        button?.layer.masksToBounds = true
        button?.titleLabel?.textAlignment = .center
        button?.setTitle("Actually, help me discover more options", for: .normal)
        button?.setTitle("Actually, help me discover more options", for: .selected)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button!)
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
        } else {
            sender.layer.borderWidth = 1
        }
    }
}
// Handle the user's selection GOOGLE PLACES SEARCH
extension YesCityDecidedQuestionView: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
        searchController?.searchBar.text = place.name
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        if destinationsForTrip.count == 0 {
            destinationsForTrip.append((searchController?.searchBar.text)!)
        } else {
            destinationsForTrip[0] = (searchController?.searchBar.text)!
        }
        SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "destinationDecidedEntered"), object: nil)
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
