//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CardView: UIView, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Class vars
    var topThingsToDoTableView: UITableView?
    var destinationPhotosCollectionView: UICollectionView?
    var cardToLoad = Int()
    var cardMode = String()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
        setUpTable()
        setUpCollectionView()
    }

    func setup() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;

        var homeAirport = String()
        var price = String()
                
        if  DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
            homeAirport = DataContainerSingleton.sharedDataContainer.homeAirport!
            price = "$350"
        } else {
            homeAirport = "???"
            price = "$350"
        }
        
        let flightsFromLabel = UILabel(frame: CGRect(x: 0, y: 335 + 10, width: 315, height: 23))
        flightsFromLabel.text = " Roundtrip flights from \(homeAirport) starting at \(price) "
        flightsFromLabel.font = UIFont.boldSystemFont(ofSize: 20)
        flightsFromLabel.textColor = UIColor.white
        flightsFromLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(flightsFromLabel)
        
        let accomodationFromLabel = UILabel(frame: CGRect(x: 0, y: flightsFromLabel.frame.maxY + 5, width: 315, height: 23))
        accomodationFromLabel.text = " Accomodation starting at \(price) a night"
        accomodationFromLabel.font = UIFont.boldSystemFont(ofSize: 20)
        accomodationFromLabel.adjustsFontSizeToFitWidth = true
        accomodationFromLabel.textColor = UIColor.white
        self.addSubview(accomodationFromLabel)

        if cardMode == "detailed" {
            let averageWeatherLabel_High = UILabel(frame: CGRect(x: 0, y: accomodationFromLabel.frame.maxY + 10, width: 315, height: 23))
            averageWeatherLabel_High.text = " Average high in June: 83°F"
            averageWeatherLabel_High.font = UIFont.boldSystemFont(ofSize: 20)
            averageWeatherLabel_High.textColor = UIColor.white
            self.addSubview(averageWeatherLabel_High)
            
            let averageWeatherLabel_Low = UILabel(frame: CGRect(x: 0, y: averageWeatherLabel_High.frame.maxY + 5, width: 315, height: 23))
            averageWeatherLabel_Low.text = " Average low in June: 70°F"
            averageWeatherLabel_Low.font = UIFont.boldSystemFont(ofSize: 20)
            averageWeatherLabel_Low.textColor = UIColor.white
            self.addSubview(averageWeatherLabel_Low)
        }
    }
 
    func setUpTable() {
        topThingsToDoTableView = UITableView(frame: CGRect.zero, style: .grouped)
        topThingsToDoTableView?.delegate = self
        topThingsToDoTableView?.dataSource = self
        topThingsToDoTableView?.separatorColor = UIColor.white
        topThingsToDoTableView?.backgroundColor = UIColor.clear
        topThingsToDoTableView?.layer.backgroundColor = UIColor.clear.cgColor
        topThingsToDoTableView?.allowsSelection = false
        topThingsToDoTableView?.backgroundView = nil
        topThingsToDoTableView?.isOpaque = false
        self.addSubview(topThingsToDoTableView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topThingsToDoTableView?.frame = CGRect(x: 0, y: 150, width: 300, height: 186)
        var frame = self.topThingsToDoTableView?.frame
        frame?.size.height = 170
        self.topThingsToDoTableView?.frame = frame!
        
        if cardMode == "card" {
            destinationPhotosCollectionView?.frame = CGRect(x: 0, y: 0, width: 315, height: 150)
        } else if cardMode == "detailed" {
            destinationPhotosCollectionView?.frame = CGRect(x: 0, y: 0, width: 375, height: 150)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestinationTopThingsToDo = thisTripDict["topThingsToDo"] as? [String] {
                        numberOfRows = thisTripDestinationTopThingsToDo.count
                    }
                }
            }
        }
        
        return numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Add destination label from data model
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestination = thisTripDict["destination"] as? String {
                        let destinationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
                        destinationLabel.font = UIFont.boldSystemFont(ofSize: 31)
                        destinationLabel.textColor = UIColor.white
                        destinationLabel.text = " " + thisTripDestination
                        self.addSubview(destinationLabel)
                    }
                }
            }
        }

        
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
        }
        
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestinationTopThingsToDo = thisTripDict["topThingsToDo"] as? [String] {
                        cell?.textLabel?.text = thisTripDestinationTopThingsToDo[indexPath.row]
                    }
                }
            }
        }
        
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = UIColor.clear
        cell?.layer.backgroundColor = UIColor.clear.cgColor
        
        return cell!
    }
    
    // Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top things to do"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 20, width: (topThingsToDoTableView?.bounds.size.width)!, height: 23))
        
        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.textColor = UIColor.white
        
        //Add destination label from data model
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestination = thisTripDict["destination"] as? String {
                        title.text = "Top things to do in \(thisTripDestination)"
                        self.addSubview(title)
                    }
                }
            }
        }
        header.addSubview(title)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(25)
    }
    
    func setUpCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 315, height: 150)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        

        destinationPhotosCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        destinationPhotosCollectionView?.layer.cornerRadius = 10
        destinationPhotosCollectionView?.delegate = self
        destinationPhotosCollectionView?.dataSource = self
        destinationPhotosCollectionView?.isPagingEnabled = true
        destinationPhotosCollectionView?.register(destinationPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "destinationPhotosCollectionViewCell")
        destinationPhotosCollectionView?.backgroundColor = UIColor.clear
        self.addSubview(destinationPhotosCollectionView!)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestinationPhotos = thisTripDict["destinationPhotos"] {
                        numberOfItems = thisTripDestinationPhotos.count
                    }
                }
            }
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "destinationPhotosCollectionViewCell", for: indexPath) as! destinationPhotosCollectionViewCell
        cell.addViews()
        
        //Load photos
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
                    if let thisTripDestinationPhotos = thisTripDict["destinationPhotos"] as? [String] {
                        cell.destinationImageView.image = UIImage(named: thisTripDestinationPhotos[indexPath.item])
                    }
                }
            }
        }
        return cell
    }

//    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
//        //Update preference vars if an existing trip
//        //Trip status
//        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
//        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
//        //New Trip VC
//        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
//        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
//        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
//        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
//        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
//        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
//        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
//        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
//        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
//        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
//        //Budget VC
//        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
//        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
//        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
//        //Suggested Destination VC
//        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
//        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
//        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
//        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
//        //Activities VC
//        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
//        //Ranking VC
//        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
//        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
//        
//        //SavedPreferences
//        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary] as NSMutableDictionary
//        
//        return fetchedSavedPreferencesForTrip
//    }
//    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
//        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
//        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
//    }
}
