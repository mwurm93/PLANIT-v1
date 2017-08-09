//
//  WhereTravellingFromQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces
import CSVImporter

class WhereTravellingFromQuestionView: UIView, UISearchControllerDelegate, UISearchBarDelegate {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
        //GOOGLE PLACES SEARCH
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var subView: UIView?
    var stateAbbreviationsDict = [Dictionary<String, String>]()
    var startingPointQuestionLabelText = "Where will you be coming from?"
    
    var geoLoader: AviasalesAirportsGeoSearchPerformer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        getStateAbbreviations()
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
        button1?.frame.origin.y = 170
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        if DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
            button1?.isHidden = false
        } else {
            button1?.isHidden = true
        }
        
        subView?.frame = CGRect(x: (bounds.size.width-275)/2, y: 100, width: 275, height: 30)
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
        questionLabel?.text = startingPointQuestionLabelText
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
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        resultsViewController?.autocompleteFilter = filter
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
            sender.removeMask(button:sender, color: UIColor.white)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton, color: UIColor.white)
            }
        }
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        UIView.animate(withDuration: 0.25) {
//            self.subView?.frame.origin.y = 0
//            self.questionLabel?.isHidden = true
//            self.button1?.isHidden = true
//        }
//    }
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//            self.subView?.frame.origin.y = 120
//            self.questionLabel?.isHidden = false
//            self.button1?.isHidden = false
//    }
}
// Handle the user's selection GOOGLE PLACES SEARCH
extension WhereTravellingFromQuestionView: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
//        let test = place.addressComponents?[0].name
//        let test1 = place.addressComponents?[1].name
//        let test2 = place.addressComponents?[2].name
//        let test3 = place.addressComponents?[3].name
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" || SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" {

            searchController?.searchBar.text = place.addressComponents?[0].name
            DataContainerSingleton.sharedDataContainer.homeAirport = place.addressComponents?[0].name
            if place.addressComponents?.count == 6 {
                DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[5].name
            } else if place.addressComponents?.count == 5 {
                DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[4].name
            } else if place.addressComponents?.count == 4 {
                DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[3].name
            } else if place.addressComponents?.count == 3 {
                DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[2].name
            } else if place.addressComponents?.count == 2 {
                DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[1].name
            }
            if DataContainerSingleton.sharedDataContainer.homeState == "United States" {
                for stateAbbreviationDict in stateAbbreviationsDict {
                    if stateAbbreviationDict["State"] == place.addressComponents?[1].name {
                        DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[1].name
                    } else if stateAbbreviationDict["State"] == place.addressComponents?[2].name {
                        DataContainerSingleton.sharedDataContainer.homeState = place.addressComponents?[2].name
                    }
                }
            }
        } else if SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint" {
            SavedPreferencesForTrip["endingPoint"] = place.addressComponents?[0].name
        }
        
        
        //Travelpayouts airport search
        geoLoader = AviasalesAirportsGeoSearchPerformer(delegate: self)
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" || SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" {
            var startingPointDict = SavedPreferencesForTrip["startingPointDict"] as! [String:Any]
            startingPointDict["latitude"] = place.coordinate.latitude as NSNumber
            startingPointDict["longitude"] = place.coordinate.longitude as NSNumber
            DataContainerSingleton.sharedDataContainer.startingPointDict = startingPointDict as NSDictionary
            
            geoLoader?.searchAirportsNearLatitude(place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else if SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint"{
            var endingPointDict = SavedPreferencesForTrip["endingPointDict"] as! [String:Any]
            endingPointDict["latitude"] = place.coordinate.latitude as NSNumber
            endingPointDict["longitude"] = place.coordinate.longitude as NSNumber
            SavedPreferencesForTrip["endingPointDict"] = endingPointDict
            
            geoLoader?.searchAirportsNearLatitude(place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
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
    func getStateAbbreviations() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "states", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
        
        }) { $0 }.onFinish { importedRecords in
        self.stateAbbreviationsDict = importedRecords
        
        }
    }
}
extension WhereTravellingFromQuestionView: AviasalesAirportsGeoSearchPerformerDelegate {
    // MARK: - AviasalesAirportsGeoSearchPerformerDelegate
    func airportsGeoSearchPerformer(_ airportsSearchPerformer: AviasalesAirportsGeoSearchPerformer!, didFound locations: [JRSDKLocation]!) {
        let location = locations.first(where: { (location) -> Bool in return location is JRSDKAirport })
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let airport = location as? JRSDKAirport {
            let airportAsData = NSKeyedArchiver.archivedData(withRootObject: airport)
            if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" || SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" {
                var startingPointDict = SavedPreferencesForTrip["startingPointDict"] as! [String:Any]
                startingPointDict["JRSDKAirport"] = airportAsData
                DataContainerSingleton.sharedDataContainer.startingPointDict = startingPointDict  as NSDictionary
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint" {
                var endingPointDict = SavedPreferencesForTrip["endingPointDict"] as! [String:Any]
                endingPointDict["JRSDKAirport"] = airportAsData
                SavedPreferencesForTrip["endingPointDict"] = endingPointDict
            }
        } else {
            if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" || SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" {
                var startingPointDict = SavedPreferencesForTrip["startingPointDict"] as! [String:Any]
                startingPointDict["JRSDKAirport"] = "noAirportFound"
                SavedPreferencesForTrip["startingPointDict"] = startingPointDict
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint" {
                var endingPointDict = SavedPreferencesForTrip["endingPointDict"] as! [String:Any]
                endingPointDict["JRSDKAirport"] = "noAirportFound"
                SavedPreferencesForTrip["endingPointDict"] = endingPointDict
            }
        }
        
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
}
