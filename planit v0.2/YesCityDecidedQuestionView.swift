//
//  YesCityDecidedQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces
import CSVImporter

class YesCityDecidedQuestionView: UIView, UISearchControllerDelegate, UISearchBarDelegate {
    
    //Class vars
    var questionLabel: UILabel?
    var button: UIButton?
    var button1: UIButton?
    //GOOGLE PLACES SEARCH
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var subView: UIView?
    var stateAbbreviationsDict = [Dictionary<String, String>]()

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
//                self.layer.borderColor = UIColor.blue.cgColor
//                self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
        subView?.frame = CGRect(x: (bounds.size.width-275)/2, y: 100, width: 275, height: 30)
        
        button?.sizeToFit()
        button?.frame.size.height = 30
        button?.frame.size.width += 20
        button?.frame.origin.x = (bounds.size.width - (button?.frame.width)!) / 2
        button?.frame.origin.y = 170
        button?.layer.cornerRadius = (button?.frame.height)! / 2
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 170
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        button1?.isHidden = true

        loadDestination()
    }
    
    func loadDestination() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int

        if destinationsForTrip.count > indexOfDestinationBeingPlanned {
            searchController?.searchBar.text = destinationsForTrip[indexOfDestinationBeingPlanned]
            button1?.isHidden = false
            button?.frame.origin.y = 220
        } else {
            button1?.isHidden = true
            button?.frame.origin.y = 170
        }
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
        questionLabel?.text = "Where do you want to go?"
        self.addSubview(questionLabel!)
        
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
        
        //Button
        button = UIButton(type: .custom)
        button?.frame = CGRect.zero
        button?.setTitleColor(UIColor.white, for: .normal)
        button?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button?.layer.borderWidth = 1
        button?.layer.borderColor = UIColor.white.cgColor
        button?.layer.masksToBounds = true
        button?.titleLabel?.textAlignment = .center
        button?.setTitle("Help me discover somewhere!", for: .normal)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Yep, that's right", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
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
}
// Handle the user's selection GOOGLE PLACES SEARCH
extension YesCityDecidedQuestionView: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
        //Display selected place in searchBar
        searchController?.searchBar.text = place.name
        
//        let test = place.addressComponents?[0].name
//        let test1 = place.addressComponents?[1].name
//        let test2 = place.addressComponents?[2].name
//        let test3 = place.addressComponents?[3].name
////
//        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        var destinationsForTripStates = (SavedPreferencesForTrip["destinationsForTripStates"] as! [String])
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        if indexOfDestinationBeingPlanned == destinationsForTrip.count {
            //write new destination
            destinationsForTrip.append((searchController?.searchBar.text)!)
            var destinationsForTripStatesToBeAppended = String()
            if place.addressComponents?.count == 6 {
                destinationsForTripStatesToBeAppended = ((place.addressComponents?[5].name)!)
            } else if place.addressComponents?.count == 5 {
                destinationsForTripStatesToBeAppended = ((place.addressComponents?[4].name)!)
            } else if place.addressComponents?.count == 4 {
                destinationsForTripStatesToBeAppended = ((place.addressComponents?[3].name)!)
            } else if place.addressComponents?.count == 3 {
                destinationsForTripStatesToBeAppended = ((place.addressComponents?[2].name)!)
            } else if place.addressComponents?.count == 2 {
                destinationsForTripStatesToBeAppended = ((place.addressComponents?[1].name)!)
            }
            if destinationsForTripStatesToBeAppended == "United States" {
                for stateAbbreviationDict in stateAbbreviationsDict {
                    if stateAbbreviationDict["State"] == place.addressComponents?[1].name {
                        destinationsForTripStatesToBeAppended = ((place.addressComponents?[1].name)!)
                    } else if stateAbbreviationDict["State"] == place.addressComponents?[2].name {
                        destinationsForTripStatesToBeAppended = ((place.addressComponents?[2].name)!)
                    }
                }
            }
            destinationsForTripStates.append(destinationsForTripStatesToBeAppended)
        } else if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            //over write
            destinationsForTrip[indexOfDestinationBeingPlanned] = (searchController?.searchBar.text)!
            if place.addressComponents?.count == 6 {
                destinationsForTripStates[indexOfDestinationBeingPlanned] = ((place.addressComponents?[5].name)!)
            } else if place.addressComponents?.count == 5 {
                destinationsForTripStates[indexOfDestinationBeingPlanned] = ((place.addressComponents?[4].name)!)
            } else if place.addressComponents?.count == 4 {
                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[3].name)!
            } else if place.addressComponents?.count == 3 {
                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[2].name)!
            } else if place.addressComponents?.count == 2 {
                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[1].name)!
            }
            if destinationsForTripStates[indexOfDestinationBeingPlanned] == "United States" {
                for stateAbbreviationDict in stateAbbreviationsDict {
                    if stateAbbreviationDict["State"] == place.addressComponents?[1].name {
                        destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[1].name)!
                    } else if stateAbbreviationDict["State"] == place.addressComponents?[2].name {
                        destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[2].name)!
                    }
                }
            }

        } else if indexOfDestinationBeingPlanned > destinationsForTrip.count {
            fatalError("indexOfDestinationBeingPlanned > destinationsForTrip.count in destinationsSwipedRightTableViewCell.swift")
        }
        SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
        SavedPreferencesForTrip["destinationsForTripStates"] = destinationsForTripStates
        
        
        //Travelpayouts airport search
        geoLoader = AviasalesAirportsGeoSearchPerformer(delegate: self)
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        if destinationsForTrip.count > destinationsForTripDictArray.count {
            destinationsForTripDictArray.append(["latitude": place.coordinate.latitude as NSNumber])
        } else {
            destinationsForTripDictArray[indexOfDestinationBeingPlanned]["latitude"] = place.coordinate.latitude as NSNumber
        }
        destinationsForTripDictArray[indexOfDestinationBeingPlanned]["longitude"] = place.coordinate.longitude as NSNumber
        SavedPreferencesForTrip["destinationsForTripDictArray"] = destinationsForTripDictArray
        
        geoLoader?.searchAirportsNearLatitude(place.coordinate.latitude, longitude: place.coordinate.longitude)

        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        var city: HDKCity?
        ServiceLocator.shared.sdkFacade.loadNearbyCities(location: location, completion: {(_ nearbyCities: [HDKCity]?, _ error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
            let SavedPreferencesForTrip2 = self.fetchSavedPreferencesForTrip()
            var destinationsForTripDictArray2 = SavedPreferencesForTrip2["destinationsForTripDictArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned2 = SavedPreferencesForTrip2["indexOfDestinationBeingPlanned"] as! Int
            city = nearbyCities?[0]
            let cityAsData = NSKeyedArchiver.archivedData(withRootObject: city)
            destinationsForTripDictArray2[indexOfDestinationBeingPlanned2]["HDKCity"] = cityAsData
            SavedPreferencesForTrip2["destinationsForTripDictArray"] = destinationsForTripDictArray2
            self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip2)

        })

        
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        //Post notification
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

extension YesCityDecidedQuestionView: AviasalesAirportsGeoSearchPerformerDelegate {
    // MARK: - AviasalesAirportsGeoSearchPerformerDelegate
    func airportsGeoSearchPerformer(_ airportsSearchPerformer: AviasalesAirportsGeoSearchPerformer!, didFound locations: [JRSDKLocation]!) {
        let location = locations.first(where: { (location) -> Bool in return location is JRSDKAirport })
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        if let airport = location as? JRSDKAirport {
            let airportAsData = NSKeyedArchiver.archivedData(withRootObject: airport)
            var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
            destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] = airportAsData
            SavedPreferencesForTrip["destinationsForTripDictArray"] = destinationsForTripDictArray
        } else {
            var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
            destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] = "noAirportFound"
            SavedPreferencesForTrip["destinationsForTripDictArray"] = destinationsForTripDictArray
        }
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
}

