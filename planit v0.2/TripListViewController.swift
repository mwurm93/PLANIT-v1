//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, WhirlyGlobeViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var existingTripsTable: UITableView!
    @IBOutlet weak var createTripButton: UIButton!
    @IBOutlet weak var addAnotherTripButton: UIButton!
    @IBOutlet weak var myTripsTitleLabel: UILabel!
    @IBOutlet weak var createTripArrow: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    @IBOutlet weak var goToBucketListButton: UIButton!
    @IBOutlet weak var bucketListButton: UIButton!
    @IBOutlet weak var beenThereButton: UIButton!
    @IBOutlet weak var fillModeButton: UIButton!
    @IBOutlet weak var pinModeButton: UIButton!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var popupBackgroundViewForInstructions: UIVisualEffectView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var welcomeToPlanitLabel: UILabel!
    
    // Outlets for instructions
    @IBOutlet weak var destinationDecidedControlView: UIView!
    @IBOutlet weak var destinationDecidedControl: UISegmentedControl!
    
    //Firebase channels
    private var channelRefHandle: FIRDatabaseHandle?
    private var channels: [Channel] = []
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    
    //Times VC viewed
    var timesViewed = [String: Int]()
    
    //Maply
    var theViewC: MaplyBaseViewController?
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white
    private var vectorDict: [String: AnyObject]?
    private var useLocalTiles = false
    var selectionColor = UIColor()
    private var selectedVectorFillDict: [String: AnyObject]?
    private var selectedVectorOutlineDict: [String: AnyObject]?

    //COPY
    var bucketListPinLocations = [[String: AnyObject]]()
    var beenTherePinLocations = [[String: AnyObject]]()
    var bucketListCountries = [String]()
    var beenThereCountries = [String]()
    
    var AddedSphereComponentObjs = [MaplyComponentObject]()
    var AddedCylinderComponentObjs = [MaplyComponentObject]()
    var AddedSphereMaplyShapeObjs = [MaplyShape]()
    var AddedCylinderMaplyShapeObjs = [MaplyShape]()
    
    var AddedSphereComponentObjs_been = [MaplyComponentObject]()
    var AddedCylinderComponentObjs_been = [MaplyComponentObject]()
    var AddedSphereMaplyShapeObjs_been = [MaplyShape]()
    var AddedCylinderMaplyShapeObjs_been = [MaplyShape]()
    
    var AddedFillComponentObjs = [MaplyComponentObject]()
    var AddedOutlineComponentObjs = [MaplyComponentObject]()
    var AddedFillVectorObjs = [MaplyVectorObject]()
    var AddedOutlineVectorObjs = [MaplyVectorObject]()
    
    var AddedFillComponentObjs_been = [MaplyComponentObject]()
    var AddedOutlineComponentObjs_been = [MaplyComponentObject]()
    var AddedFillVectorObjs_been = [MaplyVectorObject]()
    var AddedOutlineVectorObjs_been = [MaplyVectorObject]()
    var mode = "pin"
    //GOOGLE PLACES SEARCH
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var globeViewC: WhirlyGlobeViewController?
    var destinationDecidedResultBool = false
    var instructionsState = "globe"
    var currentSelectedShape = [String: AnyObject]()

    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var popupBackgroundViewDestinationDecided: UIVisualEffectView!
    
    let sectionTitles = ["Still in the works...", "Booked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timesViewed = DataContainerSingleton.sharedDataContainer.timesViewed as? [String : Int] ?? ["settings":0, "bucketList":0, "tripList":0, "newTrip":0, "swiping":0, "ranking":0, "flightSearch":0,"flightResults":0,"hotelResults":0,"booking":0]
        
        observeChannels()
        
        //GOOGLE PLACES SEARCH
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
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
        let subView = UIView(frame: CGRect(x: 15, y: 22, width: 3/5 * self.view.frame.maxX, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.insertSubview(subView, belowSubview: goToBucketListButton)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        selectionColor = UIColor(cgColor: bucketListButton.layer.backgroundColor!)
        
        bucketListButton.layer.cornerRadius = 5
        bucketListButton.layer.borderColor = UIColor.white.cgColor
        bucketListButton.layer.borderWidth = 3
        bucketListButton.layer.shadowColor = UIColor.black.cgColor
        bucketListButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        bucketListButton.layer.shadowRadius = 2
        bucketListButton.layer.shadowOpacity = 0.5
        
        beenThereButton.layer.cornerRadius = 5
        beenThereButton.layer.borderColor = UIColor.white.cgColor
        beenThereButton.layer.borderWidth = 0
        beenThereButton.layer.shadowColor = UIColor.black.cgColor
        beenThereButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        beenThereButton.layer.shadowRadius = 2
        beenThereButton.layer.shadowOpacity = 0.5
        
        fillModeButton.layer.shadowColor = UIColor.black.cgColor
        fillModeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        fillModeButton.layer.shadowRadius = 2
        fillModeButton.layer.shadowOpacity = 0.5
        
        pinModeButton.layer.shadowColor = UIColor.black.cgColor
        pinModeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        pinModeButton.layer.shadowRadius = 2
        pinModeButton.layer.shadowOpacity = 0.5

        createTripArrow.layer.shadowColor = UIColor.black.cgColor
        createTripArrow.layer.shadowOffset = CGSize(width: 2, height: 2)
        createTripArrow.layer.shadowRadius = 2
        createTripArrow.layer.shadowOpacity = 0.5
        
        createTripButton.layer.shadowColor = UIColor.black.cgColor
        createTripButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        createTripButton.layer.shadowRadius = 2
        createTripButton.layer.shadowOpacity = 0.5
        
        handleModeButtonImages()
        
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.isHidden = true
        popupBackgroundView.isUserInteractionEnabled = true
        self.popupBackgroundView.addGestureRecognizer(tap)
        
        // Set up tap outside time of day table
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.dismissDecidedDestination(touch:)))
        tap2.numberOfTapsRequired = 1
        tap2.delegate = self
        popupBackgroundViewDestinationDecided.isHidden = true
        popupBackgroundViewDestinationDecided.isUserInteractionEnabled = true
        self.popupBackgroundViewDestinationDecided.addGestureRecognizer(tap2)
        
        //Rotate segmented control view
        destinationDecidedControl.transform =  CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        for segment in self.destinationDecidedControl.subviews {
            for segmentSubview in segment.subviews {
                if segmentSubview is UILabel {
                    (segmentSubview as! UILabel).transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
                }
            }
        }
        destinationDecidedControl.frame = CGRect(x: 23, y: 59, width: 150, height: 65)
        destinationDecidedControlView.frame = CGRect(x: 167, y: 430, width: 196, height: 135)

        destinationDecidedControlView.isHidden = true
        destinationDecidedControlView.layer.cornerRadius = 10
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
            
            myTripsTitleLabel.isHidden = true
            existingTripsTable.isHidden = true
            addAnotherTripButton.isHidden = true
            goToBucketListButton.isHidden = true
            
            bucketListButton.isHidden = false
            beenThereButton.isHidden = false
            fillModeButton.isHidden = false
            pinModeButton.isHidden = false
            searchController?.searchBar.isHidden = false
            
            createTripButton.isHidden = false
            createTripArrow.isHidden = false
        
        //WhirlyGLobe
        loadWhirlyGlobe()
        }
        else {
            existingTripsTable.isHidden = false
            existingTripsTable.tableFooterView = UIView()
            existingTripsTable.layer.cornerRadius = 5
            addAnotherTripButton.isHidden = false
            goToBucketListButton.isHidden = false
            
            bucketListButton.isHidden = true
            beenThereButton.isHidden = true
            fillModeButton.isHidden = true
            pinModeButton.isHidden = true
            searchController?.searchBar.isHidden = true
            
            createTripButton.isHidden = true
            createTripArrow.isHidden = true
        }
        
//        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if timesViewed["tripList"] == 0 {
            let when = DispatchTime.now() + 0.4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInstructionsIn()
                
                let currentTimesViewed = self.timesViewed["tripList"]
                self.timesViewed["tripList"]! = currentTimesViewed! + 1
                DataContainerSingleton.sharedDataContainer.timesViewed = self.timesViewed as NSDictionary
            }
        }
        
        popupBackgroundViewForInstructions.isHidden = true
        instructionsView.isHidden = true
        instructionsView.layer.cornerRadius = 10
        let pinAttachment = NSTextAttachment()
        pinAttachment.image = #imageLiteral(resourceName: "mapPin_black")
        pinAttachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        let fillAttachment = NSTextAttachment()
        fillAttachment.image = #imageLiteral(resourceName: "paintBucket_black")
        fillAttachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        let stringForLabel = NSMutableAttributedString(string: "")
        let attachment1 = NSAttributedString(attachment: pinAttachment)
        let attachment2 = NSAttributedString(attachment: fillAttachment)
        stringForLabel.append(attachment1)
        stringForLabel.append(NSAttributedString(string:"and "))
        stringForLabel.append(attachment2)
        stringForLabel.append(NSAttributedString(string:" where you've been and what's on your bucket list..."))
        instructionsLabel.attributedText = stringForLabel
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissPopup(touch: UITapGestureRecognizer) {
            popupBackgroundView.isHidden = true
            destinationDecidedControlView.isHidden = true
        
        searchController?.searchBar.resignFirstResponder()
        let subView = UIView(frame: CGRect(x: 15, y: 22, width: 3/5 * self.view.frame.maxX, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        self.view.insertSubview(subView, belowSubview: goToBucketListButton)
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            self.view.insertSubview((self.theViewC?.view)!, belowSubview: fillModeButton)
        }
    }

    func dismissDecidedDestination(touch: UITapGestureRecognizer) {
        reloadAfterDestinationDecidedCancelled()
    }
    
    // MARK: Actions
    @IBAction func addTrip(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1

        popupBackgroundView.isHidden = false
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 71, width: 196, height: 135)
    }
    
    @IBAction func createTripButtonTouchDown(_ sender: Any) {
        createTripArrow.isHighlighted = true
    }
 
    @IBAction func createFirstTripButtonTouchedUpInside(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = 0
        
        createTripArrow.isHighlighted = false
        popupBackgroundView.isHidden = false
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 71, width: 196, height: 135)
    }
    @IBAction func createFirstTripArrowTouchedUpInside(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = 0

        popupBackgroundView.isHidden = false
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 71, width: 196, height: 135)
    }
    
    @IBAction func destinationDecidedControlValueChanged(_ sender: Any) {
        if destinationDecidedControl.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "addTripDestinationUndecided", sender: self)
        } else if destinationDecidedControl.selectedSegmentIndex == 1 {
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && DataContainerSingleton.sharedDataContainer.usertrippreferences?.count != 0 {
                loadWhirlyGlobe()
            }
            popupBackgroundViewDestinationDecided.isHidden = false
            destinationDecidedControlView.isHidden = true
            self.view.bringSubview(toFront: (self.theViewC?.view)!)
            self.view.bringSubview(toFront: (searchController?.searchBar)!)
            self.view.bringSubview(toFront: popupBackgroundViewDestinationDecided)
            self.searchController?.searchBar.isHidden = false
            searchController?.searchBar.becomeFirstResponder()
            destinationDecidedResultBool = true
        }
    }
    
    // # sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips == nil {
            return 0
        }
        else {
        return 2
        }
    }
    
    // Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var bookingStatuses: [Int] = []
        
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && countTripsBooked > 0 {
                if countTripsBooked > 0 {
                    return sectionTitles[section]
                }
            }
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 && bookingStatuses != [] {

                countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
                
                countTripsUnbooked = countTripsTotal - countTripsBooked
                
                if countTripsUnbooked > 0 {
                    return sectionTitles[section]
                }
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: existingTripsTable.bounds.size.width, height: 30))
        header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        header.layer.cornerRadius = 5

        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = sectionTitles[section]
        header.addSubview(title)

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {

            var bookingStatuses: [Int] = []
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
                return countTripsBooked
            }
            // else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 {
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
            countTripsUnbooked = countTripsTotal - countTripsBooked
            
            return countTripsUnbooked
        
        }
        
        return 0
    }
    
    var lastUnbookedStatusIndexAddedToTable: Int?
    var lastBookedStatusIndexAddedToTable: Int?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if lastUnbookedStatusIndexAddedToTable == nil {
            lastUnbookedStatusIndexAddedToTable = -1
        }
        if lastBookedStatusIndexAddedToTable == nil {
            lastBookedStatusIndexAddedToTable = -1
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingTripViewPrototypeCell", for: indexPath) as! ExistingTripTableViewCell
        
        var bookingStatuses: [Int] = []
        for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            
            let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
            if bookingStatus != nil {
            bookingStatuses.append(bookingStatus!)
            }
        }
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 0 && bookingStatuses != [] {
            for unbookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[unbookedIndex] == 0 && unbookedIndex > lastUnbookedStatusIndexAddedToTable! {
                    let addedRowInUnbookedSection = unbookedIndex
                    cell.layer.cornerRadius = 10
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
                    cell.layer.masksToBounds = true

                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInUnbookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastUnbookedStatusIndexAddedToTable = unbookedIndex
                    
                    return cell
                }
            }
        }
        else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 1 && bookingStatuses != [] {
            for bookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[bookedIndex] == 1 && bookedIndex > lastBookedStatusIndexAddedToTable!{
                    let addedRowInBookedSection = bookedIndex
                    cell.layer.cornerRadius = 5
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
                    cell.layer.masksToBounds = true
                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInBookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastBookedStatusIndexAddedToTable = bookedIndex
                    
                    return cell
                }
            }
        }
        // if  == nil {
            existingTripsTable.isHidden = true
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
        let searchForTitle = cell.existingTripTableViewLabel.text
        
        let channel = channels[(indexPath as NSIndexPath).row]
        channelRef = channelRef.child(channel.id)

        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                DataContainerSingleton.sharedDataContainer.currenttrip = trip
            }
        }
        
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? NSNumber()

        if finishedEnteringPreferencesStatus == "swiping" && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToRanking", sender: channel)
        } else if finishedEnteringPreferencesStatus == "ranking"  && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToRanking", sender: channel)
        } else if finishedEnteringPreferencesStatus == "flightSearch"  && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToRanking", sender: channel)
        } else if finishedEnteringPreferencesStatus == "flightResults"  && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToExploreHotels", sender: channel)
//        } else if finishedEnteringPreferencesStatus == "activities"  && bookingStatus == 0 {
//            super.performSegue(withIdentifier: "unbookedTripToExploreHotels", sender: self)
        } else if finishedEnteringPreferencesStatus == "hotelResults"  && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToBooking", sender: channel)
        } else if finishedEnteringPreferencesStatus == "booking"  && bookingStatus == 0 {
            super.performSegue(withIdentifier: "unbookedTripToBooking", sender: channel)
        } else {
            super.performSegue(withIdentifier: "addTripDestinationUndecided", sender: channel)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addTripDestinationUndecided" {
            let destination = segue.destination as? NewTripNameViewController
            
            var NewOrAddedTripForSegue = Int()
            
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            var numberSavedTrips: Int?
            if existing_trips == nil {
                numberSavedTrips = 0
                NewOrAddedTripForSegue = 1
            } else {
                numberSavedTrips = (existing_trips?.count)! - 1
                if currentTripIndex <= numberSavedTrips! {
                    NewOrAddedTripForSegue = 0
                } else {
                    NewOrAddedTripForSegue = 1
                }
            }
            destination?.NewOrAddedTripFromSegue = NewOrAddedTripForSegue
            destination?.newChannelRef = channelRef
        }
    }

    private func observeChannels() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(id: id, name: name))
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.existingTripsTable.rowHeight = 90


            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text
            
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    
                    //Remove from data model
                    DataContainerSingleton.sharedDataContainer.usertrippreferences?.remove(at: trip)
                    
                    //Remove from table
                    existingTripsTable.beginUpdates()
                    existingTripsTable.deleteRows(at: [indexPath], with: .left)
            
                    if existingTripsTable.numberOfRows(inSection: 0) == 0 && existingTripsTable.numberOfRows(inSection: 1) != 0{
                    //delete header
                    }
                    if existingTripsTable.numberOfRows(inSection: 0) != 0 && existingTripsTable.numberOfRows(inSection: 1) == 0{
                    //delete header
                    }
                    existingTripsTable.endUpdates()

                    if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! == 0 {
                        myTripsTitleLabel.isHidden = true
                        existingTripsTable.isHidden = true
                        addAnotherTripButton.isHidden = true
                        goToBucketListButton.isHidden = true
                        
                        
                        bucketListButton.isHidden = false
                        beenThereButton.isHidden = false
                        fillModeButton.isHidden = false
                        pinModeButton.isHidden = false
                        searchController?.searchBar.isHidden = false
                        
                        createTripButton.isHidden = false
                        createTripArrow.isHidden = false
                        
                        //WhirlyGLobe
                        loadWhirlyGlobe()
                    }
                    //Return if delete cell trip name found
                    return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Leave trip"
    }

    //MARK: Custom Functions
    private func loadWhirlyGlobe() {
        // Create an empty globe and add it to the view
        theViewC = WhirlyGlobeViewController()
        self.view.addSubview(theViewC!.view)
        theViewC!.view.frame = self.view.bounds
        addChildViewController(theViewC!)
        self.view.sendSubview(toBack: theViewC!.view)
        self.view.sendSubview(toBack: backgroundBlurFilterView)
        self.view.sendSubview(toBack: backgroundView)
        
        globeViewC = theViewC as? WhirlyGlobeViewController
        
        theViewC!.clearColor = UIColor.clear
        
        // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
        theViewC!.frameInterval = 2
        
        // set up the data source
        
        if useLocalTiles {
            if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
                let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
                layer.handleEdges = false
                layer.coverPoles = false
                layer.requireElev = false
                layer.waitLoad = true
                layer.drawPriority = 0
                layer.singleLevelLoading = false
                
                theViewC!.add(layer)
            }
        } else {
            // Because this is a remote tile set, we'll want a cache directory
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let tilesCacheDir = "\(baseCacheDir)/stamentiles/"
            let maxZoom = Int32(18)
            
            // Stamen Terrain Tiles, courtesy of Stamen Design under the Creative Commons Attribution License.
            // Data by OpenStreetMap under the Open Data Commons Open Database License.
            guard let tileSource = MaplyRemoteTileSource(
                baseURL: "http://tile.stamen.com/watercolor/",
                ext: "png",
                minZoom: 0,
                maxZoom: maxZoom) else {
                    // can't create remote tile source
                    return
            }
            tileSource.cacheDir = tilesCacheDir
            let layer = MaplyQuadImageTilesLayer(tileSource: tileSource)
            layer?.handleEdges = (globeViewC != nil)
            layer?.coverPoles = (globeViewC != nil)
            layer?.requireElev = false
            layer?.waitLoad = false
            layer?.drawPriority = 0
            layer?.singleLevelLoading = false
            theViewC!.add(layer!)
        }
        
        // start up over Madrid, center of the old-world
        if let globeViewC = globeViewC {
            globeViewC.height = 1.2
            globeViewC.keepNorthUp = true
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-96.7970, 32.7767), time: 1.5)
            globeViewC.keepNorthUp = false
            globeViewC.setZoomLimitsMin(0.001, max: 1.2)
        }
        vectorDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: false as AnyObject,
            kMaplyColor: UIColor.white,
            kMaplyVecWidth: 3.0 as AnyObject
        ]
        
        if let globeViewC = globeViewC {
            globeViewC.delegate = self
        }
        
        // add the countries
        addCountries()
        
        //Load previously placed pins and countries
        bucketListPinLocations = DataContainerSingleton.sharedDataContainer.bucketListPinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
        beenTherePinLocations = DataContainerSingleton.sharedDataContainer.beenTherePinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
        bucketListCountries = DataContainerSingleton.sharedDataContainer.bucketListCountries ?? [String]()
        beenThereCountries = DataContainerSingleton.sharedDataContainer.beenThereCountries ?? [String]()
        
        //Install bucket list pins
        if bucketListPinLocations.count != 0 {
            var pinLocationSphere = [MaplyCoordinate]()
            var pinLocationCylinder = [MaplyCoordinate]()
            for bucketListPinLocation in bucketListPinLocations {
                pinLocationSphere.append(MaplyCoordinate(x: bucketListPinLocation["x"] as! Float, y: bucketListPinLocation["y"] as! Float))
                pinLocationCylinder.append(MaplyCoordinate(x: bucketListPinLocation["x"] as! Float, y: bucketListPinLocation["y"] as! Float))
            }
            let pinTopSphere = pinLocationSphere.map { location -> MaplyShapeSphere in
                let sphere = MaplyShapeSphere()
                sphere.center = location
                sphere.radius = 0.007
                sphere.height = 0.022
                sphere.selectable = true
                sphere.userObject = location
                return sphere
            }
            let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
                let cylinder = MaplyShapeCylinder()
                cylinder.baseCenter = location
                cylinder.baseHeight = 0
                cylinder.radius = 0.003
                cylinder.height = 0.015
                cylinder.selectable = true
                cylinder.userObject = location
                return cylinder
            }
            
            let AddedSphereComponentObj = (self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: UIColor(cgColor: bucketListButton.layer.backgroundColor!)]))!
            let AddedCylinderComponentObj = (self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)]))!
            AddedSphereComponentObjs.append(AddedSphereComponentObj)
            AddedCylinderComponentObjs.append(AddedCylinderComponentObj)
            AddedSphereMaplyShapeObjs.append(pinTopSphere[0])
            AddedCylinderMaplyShapeObjs.append(pinCylinder[0])
        }
        //Install been there pins
        if beenTherePinLocations.count != 0 {
            var pinLocationSphere = [MaplyCoordinate]()
            var pinLocationCylinder = [MaplyCoordinate]()
            for beenTherePinLocation in beenTherePinLocations {
                pinLocationSphere.append(MaplyCoordinate(x: beenTherePinLocation["x"] as! Float, y: beenTherePinLocation["y"] as! Float))
                pinLocationCylinder.append(MaplyCoordinate(x: beenTherePinLocation["x"] as! Float, y: beenTherePinLocation["y"] as! Float))
            }
            let pinTopSphere = pinLocationSphere.map { location -> MaplyShapeSphere in
                let sphere = MaplyShapeSphere()
                sphere.center = location
                sphere.radius = 0.007
                sphere.height = 0.022
                sphere.selectable = true
                sphere.userObject = location
                return sphere
            }
            let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
                let cylinder = MaplyShapeCylinder()
                cylinder.baseCenter = location
                cylinder.baseHeight = 0
                cylinder.radius = 0.003
                cylinder.height = 0.015
                cylinder.selectable = true
                cylinder.userObject = location
                return cylinder
            }
            
            let AddedSphereComponentObj = (self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: UIColor(cgColor: beenThereButton.layer.backgroundColor!)]))!
            let AddedCylinderComponentObj = (self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)]))!
            AddedSphereComponentObjs_been.append(AddedSphereComponentObj)
            AddedCylinderComponentObjs_been.append(AddedCylinderComponentObj)
            AddedSphereMaplyShapeObjs_been.append(pinTopSphere[0])
            AddedCylinderMaplyShapeObjs_been.append(pinCylinder[0])
        }
    }
    
    private func handleSelection(selectedObject: NSObject) {
        
        var AddedFillComponentObj = MaplyComponentObject()
        var AddedOutlineComponentObj = MaplyComponentObject()
        var AddedFillComponentObj_been = MaplyComponentObject()
        var AddedOutlineComponentObj_been = MaplyComponentObject()
        
        
        if let selectedObject = selectedObject as? MaplyVectorObject {
            let loc = selectedObject.centroid()
            var subtitle = ""
            
            if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
                
                if selectedObject.attributes["selectionStatus"] as! String == "tbd"  {
                    subtitle = "Added to bucket list"
                    
                    selectedVectorFillDict = [
                        kMaplyColor: UIColor(cgColor: bucketListButton.layer.backgroundColor!),
                        kMaplySelectable: true as AnyObject,
                        kMaplyFilled: true as AnyObject,
                        kMaplyVecWidth: 3.0 as AnyObject,
                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                        kMaplySubdivEpsilon: 0.15 as AnyObject
                    ]
                    AddedFillComponentObj = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict))!
                    AddedOutlineComponentObj = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict))!
                    AddedFillComponentObjs.append(AddedFillComponentObj)
                    AddedOutlineComponentObjs.append(AddedOutlineComponentObj)
                    AddedFillVectorObjs.append(selectedObject)
                    AddedOutlineVectorObjs.append(selectedObject)
                    
                    //COPY
                    bucketListCountries.append(selectedObject.userObject as! String)
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.bucketListCountries = bucketListCountries as [String]
                    
                    selectedObject.attributes.setValue("bucketList", forKey: "selectionStatus")
                    
                } else if selectedObject.attributes["selectionStatus"] as! String == "bucketList" {
                    subtitle = "Nevermind"
                    var index = 0
                    for vectorObject in AddedFillVectorObjs {
                        if vectorObject.userObject as! String == selectedObject.userObject as! String {
                            theViewC?.remove(AddedFillComponentObjs[index])
                            theViewC?.remove(AddedOutlineComponentObjs[index])
                            AddedFillComponentObjs.remove(at: index)
                            AddedOutlineComponentObjs.remove(at: index)
                            AddedFillVectorObjs.remove(at: index)
                            AddedOutlineVectorObjs.remove(at: index)
                            
                            //COPY
                            bucketListCountries.remove(at: index)
                            //Save to singleton
                            DataContainerSingleton.sharedDataContainer.bucketListCountries = bucketListCountries as [String]
                        } else {
                            index += 1
                        }
                    }
                    
                    selectedObject.attributes.setValue("tbd", forKey: "selectionStatus")
                } else {
                    //Remove
                    var index = 0
                    for vectorObject in AddedFillVectorObjs_been {
                        if vectorObject.userObject as! String == selectedObject.userObject as! String {
                            theViewC?.remove(self.AddedFillComponentObjs_been[index])
                            theViewC?.remove(self.AddedOutlineComponentObjs_been[index])
                            AddedFillComponentObjs_been.remove(at: index)
                            AddedOutlineComponentObjs_been.remove(at: index)
                            AddedFillVectorObjs_been.remove(at: index)
                            AddedOutlineVectorObjs_been.remove(at: index)
                            
                            //COPY
                            beenThereCountries.remove(at: index)
                            //Save to singleton
                            DataContainerSingleton.sharedDataContainer.beenThereCountries = beenThereCountries as [String]
                        } else {
                            index += 1
                        }
                    }
                    //Add
                    subtitle = "Added to bucket list"
                    
                    selectedVectorFillDict = [
                        kMaplyColor: UIColor(cgColor: bucketListButton.layer.backgroundColor!),
                        kMaplySelectable: true as AnyObject,
                        kMaplyFilled: true as AnyObject,
                        kMaplyVecWidth: 3.0 as AnyObject,
                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                        kMaplySubdivEpsilon: 0.15 as AnyObject
                    ]
                    AddedFillComponentObj = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict))!
                    AddedOutlineComponentObj = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict))!
                    AddedFillComponentObjs.append(AddedFillComponentObj)
                    AddedOutlineComponentObjs.append(AddedOutlineComponentObj)
                    AddedFillVectorObjs.append(selectedObject)
                    AddedOutlineVectorObjs.append(selectedObject)
                    
                    //COPY
                    bucketListCountries.append(selectedObject.userObject as! String)
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.bucketListCountries = bucketListCountries as [String]
                    
                    selectedObject.attributes.setValue("bucketList", forKey: "selectionStatus")
                }
                
            } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!) {
                if selectedObject.attributes["selectionStatus"] as! String == "tbd" {
                    subtitle = "Already been here"
                    
                    selectedVectorFillDict = [
                        kMaplyColor: UIColor(cgColor: beenThereButton.layer.backgroundColor!),
                        kMaplySelectable: true as AnyObject,
                        kMaplyFilled: true as AnyObject,
                        kMaplyVecWidth: 3.0 as AnyObject,
                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                        kMaplySubdivEpsilon: 0.15 as AnyObject
                    ]
                    
                    AddedFillComponentObj_been = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict))!
                    AddedOutlineComponentObj_been = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict))!
                    AddedFillComponentObjs_been.append(AddedFillComponentObj_been)
                    AddedOutlineComponentObjs_been.append(AddedOutlineComponentObj_been)
                    AddedFillVectorObjs_been.append(selectedObject)
                    AddedOutlineVectorObjs_been.append(selectedObject)
                    
                    //COPY
                    beenThereCountries.append(selectedObject.userObject as! String)
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.beenThereCountries = beenThereCountries as [String]
                    
                    selectedObject.attributes.setValue("beenThere", forKey: "selectionStatus")
                } else if selectedObject.attributes["selectionStatus"] as! String == "beenThere" {
                    subtitle = "Nevermind"
                    var index = 0
                    for vectorObject in AddedFillVectorObjs_been {
                        if vectorObject.userObject as! String == selectedObject.userObject as! String {
                            theViewC?.remove(self.AddedFillComponentObjs_been[index])
                            theViewC?.remove(self.AddedOutlineComponentObjs_been[index])
                            AddedFillComponentObjs_been.remove(at: index)
                            AddedOutlineComponentObjs_been.remove(at: index)
                            AddedFillVectorObjs_been.remove(at: index)
                            AddedOutlineVectorObjs_been.remove(at: index)
                            
                            //COPY
                            beenThereCountries.remove(at: index)
                            //Save to singleton
                            DataContainerSingleton.sharedDataContainer.beenThereCountries = beenThereCountries as [String]
                        } else {
                            index += 1
                        }
                    }
                    selectedObject.attributes.setValue("tbd", forKey: "selectionStatus")
                } else {
                    subtitle = "Already been here"
                    //Remove
                    var index = 0
                    for vectorObject in AddedFillVectorObjs {
                        if vectorObject.userObject as! String == selectedObject.userObject as! String {
                            theViewC?.remove(AddedFillComponentObjs[index])
                            theViewC?.remove(AddedOutlineComponentObjs[index])
                            AddedFillComponentObjs.remove(at: index)
                            AddedOutlineComponentObjs.remove(at: index)
                            AddedFillVectorObjs.remove(at: index)
                            AddedOutlineVectorObjs.remove(at: index)
                            
                            //COPY
                            bucketListCountries.remove(at: index)
                            //Save to singleton
                            DataContainerSingleton.sharedDataContainer.bucketListCountries = bucketListCountries as [String]

                        } else {
                            index += 1
                        }
                    }
                    
                    //Add
                    selectedVectorFillDict = [
                        kMaplyColor: UIColor(cgColor: beenThereButton.layer.backgroundColor!),
                        kMaplySelectable: true as AnyObject,
                        kMaplyFilled: true as AnyObject,
                        kMaplyVecWidth: 3.0 as AnyObject,
                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                        kMaplySubdivEpsilon: 0.15 as AnyObject
                    ]
                    
                    AddedFillComponentObj_been = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict))!
                    AddedOutlineComponentObj_been = (self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict))!
                    AddedFillComponentObjs_been.append(AddedFillComponentObj_been)
                    AddedOutlineComponentObjs_been.append(AddedOutlineComponentObj_been)
                    AddedFillVectorObjs_been.append(selectedObject)
                    AddedOutlineVectorObjs_been.append(selectedObject)
                    
                    //COPY
                    beenThereCountries.append(selectedObject.userObject as! String)
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.beenThereCountries = beenThereCountries as [String]
                    
                    selectedObject.attributes.setValue("beenThere", forKey: "selectionStatus")
                }
            }
            
            
            addAnnotationWithTitle(title: selectedObject.userObject as! String, subtitle: subtitle, loc: loc)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.theViewC?.clearAnnotations()
        })
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject, atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
        if let selectedObj = selectedObj as? MaplyShape {
            let a = MaplyAnnotation()
            let destinationDecidedButtonAnnotation = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
            destinationDecidedButtonAnnotation.setTitle("Plan trip here", for: .normal)
            destinationDecidedButtonAnnotation.sizeToFit()
            destinationDecidedButtonAnnotation.setTitleColor(UIColor.white, for: .normal)
            destinationDecidedButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
            let currentSize = destinationDecidedButtonAnnotation.titleLabel?.font.pointSize
            destinationDecidedButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: currentSize! - 1.5)
            destinationDecidedButtonAnnotation.backgroundColor = UIColor(red: 79/255, green: 146/255, blue: 255/255, alpha: 1)
            destinationDecidedButtonAnnotation.layer.cornerRadius = destinationDecidedButtonAnnotation.frame.height / 2
            destinationDecidedButtonAnnotation.titleLabel?.textAlignment = .center
            destinationDecidedButtonAnnotation.addTarget(self, action: #selector(self.bucketListButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let removePinButtonAnnotation = UIButton(frame: CGRect(x: 0, y: destinationDecidedButtonAnnotation.frame.height + 5, width: 150, height: 20))
            removePinButtonAnnotation.setTitle("Remove pin", for: .normal)
            removePinButtonAnnotation.sizeToFit()
            removePinButtonAnnotation.frame.origin = CGPoint(x: destinationDecidedButtonAnnotation.frame.midX - removePinButtonAnnotation.frame.width / 2, y: destinationDecidedButtonAnnotation.frame.height + 5)
            removePinButtonAnnotation.setTitleColor(UIColor.white, for: .normal)
            removePinButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
            let removePinCurrentSize = destinationDecidedButtonAnnotation.titleLabel?.font.pointSize
            removePinButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: removePinCurrentSize! - 1.5)
            removePinButtonAnnotation.backgroundColor = UIColor.gray
            removePinButtonAnnotation.layer.cornerRadius = destinationDecidedButtonAnnotation.frame.height / 2
            removePinButtonAnnotation.titleLabel?.textAlignment = .center
            currentSelectedShape["selectedShapeLocation"] = selectedObj.userObject as AnyObject
            currentSelectedShape["selectedShapeColor"] = selectedObj.color as AnyObject
            removePinButtonAnnotation.addTarget(self, action: #selector(self.removePinButtonAnnotationButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)

            
            let cancelButtonAnnotation = UIButton(frame: CGRect(x: 0, y: removePinButtonAnnotation.frame.maxY + 5, width: destinationDecidedButtonAnnotation.frame.width, height: 15))
            cancelButtonAnnotation.setTitle("Cancel", for: .normal)
            cancelButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            cancelButtonAnnotation.setTitleColor(UIColor.gray, for: .normal)
            cancelButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
            cancelButtonAnnotation.titleLabel?.textAlignment = .justified
            cancelButtonAnnotation.addTarget(self, action: #selector(self.cancelButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let frameForAnnotationContentView = CGRect(x: 0, y: 0, width: destinationDecidedButtonAnnotation.frame.width, height: destinationDecidedButtonAnnotation.frame.height + removePinButtonAnnotation.frame.height + 5 + cancelButtonAnnotation.frame.height + 5)
            let annotationContentView = UIView(frame: frameForAnnotationContentView)
            annotationContentView.addSubview(destinationDecidedButtonAnnotation)
            annotationContentView.addSubview(removePinButtonAnnotation)
            annotationContentView.addSubview(cancelButtonAnnotation)
            
            a.contentView = annotationContentView
            theViewC?.addAnnotation(a, forPoint: coord, offset: CGPoint.zero)
            globeViewC?.keepNorthUp = true
            globeViewC?.animate(toPosition: coord, onScreen: (theViewC?.view.center)!, time: 1)
            globeViewC?.keepNorthUp = false
            return
        }
        
        if mode == "fill" {
            handleSelection(selectedObject: selectedObj)
        } else if mode == "pin" {
            if let selectedObj = selectedObj as? MaplyMarker {
                addAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObj.loc)
            } else {
                let pinLocationSphere = [coord]
                let pinLocationCylinder = [coord]
                // convert capitals into spheres. Let's do it functional!
                let pinTopSphere = pinLocationSphere.map { location -> MaplyShapeSphere in
                    let sphere = MaplyShapeSphere()
                    sphere.center = location
                    sphere.radius = 0.007
                    sphere.height = 0.022
                    sphere.selectable = true
                    sphere.userObject = location
                    return sphere
                }
                let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
                    let cylinder = MaplyShapeCylinder()
                    cylinder.baseCenter = location
                    cylinder.baseHeight = 0
                    cylinder.radius = 0.003
                    cylinder.height = 0.015
                    cylinder.selectable = true
                    cylinder.userObject = location
                    return cylinder
                }
                
                let AddedSphereComponentObj = (self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: selectionColor]))!
                let AddedCylinderComponentObj = (self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)]))!
                if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
                    AddedSphereComponentObjs.append(AddedSphereComponentObj)
                    AddedCylinderComponentObjs.append(AddedCylinderComponentObj)
                    AddedSphereMaplyShapeObjs.append(pinTopSphere[0])
                    AddedCylinderMaplyShapeObjs.append(pinCylinder[0])
                    
                    //COPY
                    bucketListPinLocations.append(["x": coord.x as AnyObject,"y": coord.y as AnyObject])
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.bucketListPinLocations = bucketListPinLocations as [NSDictionary]
                } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!){
                    AddedSphereComponentObjs_been.append(AddedSphereComponentObj)
                    AddedCylinderComponentObjs_been.append(AddedCylinderComponentObj)
                    AddedSphereMaplyShapeObjs_been.append(pinTopSphere[0])
                    AddedCylinderMaplyShapeObjs_been.append(pinCylinder[0])
                    
                    //COPY
                    beenTherePinLocations.append(["x": coord.x as AnyObject,"y": coord.y as AnyObject])
                    //Save to singleton
                    DataContainerSingleton.sharedDataContainer.beenTherePinLocations = beenTherePinLocations as [NSDictionary]
                }
                
                var subtitle = String()
                if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
                    subtitle = "Added to bucket list"
                } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!){
                    subtitle = "Already been here"
                }
                
                addAnnotationWithTitle(title: "Pin", subtitle: subtitle, loc: coord)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.theViewC?.clearAnnotations()
            })
            
        }
    }
    
    func addAnnotationWithTitle(title: String, subtitle: String, loc:MaplyCoordinate) {
        theViewC?.clearAnnotations()
        let a = MaplyAnnotation()
        a.title = title
        a.subTitle = subtitle
        theViewC?.addAnnotation(a, forPoint: loc, offset: CGPoint.zero)
        globeViewC?.keepNorthUp = true
        globeViewC?.animate(toPosition: loc, onScreen: (theViewC?.view.center)!, time: 1)
        globeViewC?.keepNorthUp = false
    }
    
    func bucketListButtonAnnotationClicked(sender:UIButton) {
        //PERFORM SEGUE TO DESTINATION DECIDED FLOW
    }
    
    func removePinButtonAnnotationButtonAnnotationClicked(sender:UIButton) {
        var index = 0
        for addedSphere in AddedSphereMaplyShapeObjs {
            let sphereInArray = addedSphere.userObject as! MaplyCoordinate
            let selectedSphere = currentSelectedShape["selectedShapeLocation"] as! MaplyCoordinate
            
            if sphereInArray.x == selectedSphere.x && sphereInArray.y == selectedSphere.y {
                theViewC?.remove(AddedCylinderComponentObjs[index])
                theViewC?.remove(AddedSphereComponentObjs[index])
                AddedSphereComponentObjs.remove(at: index)
                AddedCylinderComponentObjs.remove(at: index)
                AddedSphereMaplyShapeObjs.remove(at: index)
                AddedCylinderMaplyShapeObjs.remove(at: index)
                
                //COPY
                bucketListPinLocations.remove(at: index)
                //Save to singleton
                DataContainerSingleton.sharedDataContainer.bucketListPinLocations = bucketListPinLocations as [NSDictionary]

                theViewC?.clearAnnotations()
            } else {
                index += 1
            }
        }
        index = 0
        for addedSphere in AddedSphereMaplyShapeObjs_been {
            let sphereInArray = addedSphere.userObject as! MaplyCoordinate
            let selectedSphere = currentSelectedShape["selectedShapeLocation"] as! MaplyCoordinate
            
            if sphereInArray.x == selectedSphere.x && sphereInArray.y == selectedSphere.y {
                theViewC?.remove(AddedCylinderComponentObjs_been[index])
                theViewC?.remove(AddedSphereComponentObjs_been[index])
                AddedSphereComponentObjs_been.remove(at: index)
                AddedCylinderComponentObjs_been.remove(at: index)
                AddedSphereMaplyShapeObjs_been.remove(at: index)
                AddedCylinderMaplyShapeObjs_been.remove(at: index)
                
                //COPY
                beenTherePinLocations.remove(at: index)
                //Save to singleton
                DataContainerSingleton.sharedDataContainer.bucketListPinLocations = bucketListPinLocations as [NSDictionary]

                theViewC?.clearAnnotations()
            } else {
                index += 1
            }
        }
    }
    
    func cancelButtonAnnotationClicked(sender:UIButton) {
            reloadAfterDestinationDecidedCancelled()
    }
    
    func reloadAfterDestinationDecidedCancelled() {
        theViewC?.clearAnnotations()
        popupBackgroundView.isHidden = true
        popupBackgroundViewDestinationDecided.isHidden = true
        destinationDecidedControlView.isHidden = true
        destinationDecidedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        self.view.insertSubview((self.theViewC?.view)!, belowSubview: fillModeButton)
        destinationDecidedResultBool = false
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && DataContainerSingleton.sharedDataContainer.usertrippreferences?.count != 0 {
            theViewC?.view.isHidden = true
            searchController?.searchBar.isHidden = true
        }
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if destinationDecidedResultBool == true {
            reloadAfterDestinationDecidedCancelled()
        }
    }
    
    private func addCountries() {
        // handle this in another thread
        let queue = DispatchQueue.global()
        queue.async() {
            
            //COPY
            var alphabeticalBucketListCountries = [String]()
            var alphabeticalBeenThereCountries = [String]()
            
            let bundle = Bundle.main
            let allOutlines = bundle.paths(forResourcesOfType: "geojson", inDirectory: "country_json_50m")
            for outline in allOutlines {
                if let jsonData = NSData(contentsOfFile: outline),
                    let wgVecObj = MaplyVectorObject(fromGeoJSON: jsonData as Data) {
                    wgVecObj.selectable = true
                    // the admin tag from the country outline geojson has the country name ­ save
                    let attrs = wgVecObj.attributes
                    if let vecName = attrs.object(forKey: "ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                        
                        if (vecName.description.characters.count) > 0 {
                            let label = MaplyScreenLabel()
                            label.text = vecName.description
                            label.loc = wgVecObj.centroid()
                            label.layoutImportance = 10.0
                            self.theViewC?.addScreenLabels([label],
                                                           desc: [
                                                            kMaplyFont: UIFont.boldSystemFont(ofSize: 14.0),
                                                            kMaplyTextColor: UIColor.darkGray,
                                                            kMaplyMinVis: 0.005,
                                                            kMaplyMaxVis: 0.6
                                ])
                        }
                        attrs.setValue("tbd", forKey: "selectionStatus")
                        self.theViewC?.addVectors([wgVecObj], desc: self.vectorDict)
                        
                        //COPY
                        if self.bucketListCountries.count != 0 {
                            if self.bucketListCountries.contains(vecName as! String) {
                                if (vecName.description.characters.count) > 0 {
                                    self.selectedVectorFillDict = [
                                        kMaplyColor: UIColor(cgColor: self.bucketListButton.layer.backgroundColor!),
                                        kMaplySelectable: true as AnyObject,
                                        kMaplyFilled: true as AnyObject,
                                        kMaplyVecWidth: 3.0 as AnyObject,
                                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                                        kMaplySubdivEpsilon: 0.15 as AnyObject
                                    ]
                                    var AddedFillComponentObj = MaplyComponentObject()
                                    var AddedOutlineComponentObj = MaplyComponentObject()
                                    
                                    attrs.setValue("bucketList", forKey: "selectionStatus")
                                    
                                    AddedFillComponentObj = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorFillDict))!
                                    AddedOutlineComponentObj = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorOutlineDict))!
                                    self.AddedFillComponentObjs.append(AddedFillComponentObj)
                                    self.AddedOutlineComponentObjs.append(AddedOutlineComponentObj)
                                    self.AddedFillVectorObjs.append(wgVecObj)
                                    self.AddedOutlineVectorObjs.append(wgVecObj)
                                    alphabeticalBucketListCountries.append(wgVecObj.userObject as! String)
                                }
                            }
                        }
                        if self.beenThereCountries.count != 0 {
                            if self.beenThereCountries.contains(vecName as! String) {
                                if (vecName.description.characters.count) > 0 {
                                    self.selectedVectorFillDict = [
                                        kMaplyColor: UIColor(cgColor: self.beenThereButton.layer.backgroundColor!),
                                        kMaplySelectable: true as AnyObject,
                                        kMaplyFilled: true as AnyObject,
                                        kMaplyVecWidth: 3.0 as AnyObject,
                                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
                                        kMaplySubdivEpsilon: 0.15 as AnyObject
                                    ]
                                    var AddedFillComponentObj_been = MaplyComponentObject()
                                    var AddedOutlineComponentObj_been = MaplyComponentObject()
                                    
                                    attrs.setValue("beenThere", forKey: "selectionStatus")
                                    
                                    AddedFillComponentObj_been = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorFillDict))!
                                    AddedOutlineComponentObj_been = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorOutlineDict))!
                                    self.AddedFillComponentObjs_been.append(AddedFillComponentObj_been)
                                    self.AddedOutlineComponentObjs_been.append(AddedOutlineComponentObj_been)
                                    self.AddedFillVectorObjs_been.append(wgVecObj)
                                    self.AddedOutlineVectorObjs_been.append(wgVecObj)
                                    alphabeticalBeenThereCountries.append(wgVecObj.userObject as! String)
                                }
                            }
                        }
                    }
                }
            }
            
            //COPY
            //Save alphabetically reordered countries to singleton
            DataContainerSingleton.sharedDataContainer.bucketListCountries = alphabeticalBucketListCountries
            DataContainerSingleton.sharedDataContainer.beenThereCountries = alphabeticalBeenThereCountries
            self.bucketListCountries = alphabeticalBucketListCountries
            self.beenThereCountries = alphabeticalBeenThereCountries
        }
    }
    
    func handleModeButtonImages() {
        if mode == "pin" {
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin"), for: .normal)
            pinModeButton.layer.shadowOpacity = 0.6
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket_grey"), for: .normal)
            fillModeButton.layer.shadowOpacity = 0.2
        } else if mode == "fill" {
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin_grey"), for: .normal)
            pinModeButton.layer.shadowOpacity = 0.2
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket"), for: .normal)
            fillModeButton.layer.shadowOpacity = 0.6
        }
    }
    
    func animateInstructionsIn(){
        instructionsView.layer.isHidden = false
        searchController?.searchBar.isHidden = true
        instructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        instructionsView.alpha = 0
        self.view.insertSubview((self.theViewC?.view)!, belowSubview: self.instructionsView)
        
        self.fillModeButton.isUserInteractionEnabled = false
        self.pinModeButton.isUserInteractionEnabled = false
        self.bucketListButton.isUserInteractionEnabled = false
        self.beenThereButton.isUserInteractionEnabled = false
        self.createTripButton.isUserInteractionEnabled = false
        self.createTripArrow.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundViewForInstructions.isHidden = false
            self.instructionsView.alpha = 1
            self.instructionsView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func instructionsViewGotItButtonTouchedUpInside(_ sender: Any) {
        if instructionsState == "newTrip" {
            UIView.animate(withDuration: 0.3, animations: {
                self.instructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.instructionsView.alpha = 0
                self.searchController?.searchBar.isHidden = false
                self.popupBackgroundViewForInstructions.isHidden = true
                self.view.insertSubview((self.theViewC?.view)!, belowSubview: self.fillModeButton)
                self.fillModeButton.isUserInteractionEnabled = true
                self.pinModeButton.isUserInteractionEnabled = true
                self.bucketListButton.isUserInteractionEnabled = true
                self.beenThereButton.isUserInteractionEnabled = true
                self.createTripButton.isUserInteractionEnabled = true
                self.createTripArrow.isUserInteractionEnabled = true
            }) { (Success:Bool) in
                self.instructionsView.layer.isHidden = true
                self.instructionsState = "globe"
            }
        } else if instructionsState == "globe" {
            instructionsLabel.text = "...and then start planning a trip!"
            instructionsState = "newTrip"
            
            UIView.animate(withDuration: 0.3, animations: {
                self.instructionsView.frame = CGRect(x: 50, y: 70, width: 275, height: 62)
                self.welcomeToPlanitLabel.isHidden = true
                self.instructionsLabel.frame = CGRect(x: 0, y: 1, width: 275, height: 30)
                self.gotItButton.frame = CGRect(x: 0, y: 30, width: 275, height: 30)
            })
        }
    }

    @IBAction func bucketListButtonTouchedUpInside(_ sender: Any) {
        bucketListButton.layer.borderWidth = 3
        beenThereButton.layer.borderWidth = 0
        selectionColor = UIColor(cgColor: bucketListButton.layer.backgroundColor!)
        
    }
    @IBAction func beenThereButtonTouchedUpInside(_ sender: Any) {
        bucketListButton.layer.borderWidth = 0
        beenThereButton.layer.borderWidth = 3
        selectionColor = UIColor(cgColor: beenThereButton.layer.backgroundColor!)
    }
    
    @IBAction func fillModeButtonTouchedUpInside(_ sender: Any) {
        mode = "fill"
        handleModeButtonImages()
    }
    @IBAction func pinModeButtonTouchedUpInside(_ sender: Any) {
        mode = "pin"
        handleModeButtonImages()
    }
}
// Handle the user's selection GOOGLE PLACES SEARCH
extension TripListViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        popupBackgroundViewDestinationDecided.isHidden = true
        
        if destinationDecidedResultBool == false {
        mode = "pin"
        handleModeButtonImages()
        let pinLocationSphere = [WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))]
        let pinLocationCylinder = [WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))]
        let pinTopSphere = pinLocationSphere.map { location -> MaplyShapeSphere in
            let sphere = MaplyShapeSphere()
            sphere.center = WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))
            sphere.radius = 0.007
            sphere.height = 0.022
            sphere.selectable = true
            sphere.userObject = location
            return sphere
        }
        let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
            let cylinder = MaplyShapeCylinder()
            cylinder.baseCenter = WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))
            cylinder.baseHeight = 0
            cylinder.radius = 0.003
            cylinder.height = 0.015
            cylinder.selectable = true
            cylinder.userObject = location
            return cylinder
        }
            
        let AddedSphereComponentObj = self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: selectionColor])
        let AddedCylinderComponentObj = self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)])
        
            if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
                AddedSphereComponentObjs.append(AddedSphereComponentObj!)
                AddedCylinderComponentObjs.append(AddedCylinderComponentObj!)
                AddedSphereMaplyShapeObjs.append(pinTopSphere[0])
                AddedCylinderMaplyShapeObjs.append(pinCylinder[0])
                
                //COPY
                bucketListPinLocations.append(["x": pinLocationSphere[0].x as AnyObject,"y": pinLocationSphere[0].y as AnyObject])
                //Save to singleton
                DataContainerSingleton.sharedDataContainer.bucketListPinLocations = bucketListPinLocations as [NSDictionary]
            } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!){
                AddedSphereComponentObjs_been.append(AddedSphereComponentObj!)
                AddedCylinderComponentObjs_been.append(AddedCylinderComponentObj!)
                AddedSphereMaplyShapeObjs_been.append(pinTopSphere[0])
                AddedCylinderMaplyShapeObjs_been.append(pinCylinder[0])

                //COPY
                beenTherePinLocations.append(["x": pinLocationSphere[0].x as AnyObject,"y": pinLocationSphere[0].y as AnyObject])
                //Save to singleton
                DataContainerSingleton.sharedDataContainer.beenTherePinLocations = beenTherePinLocations as [NSDictionary]
            }
            
        var subtitle = String()
        if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
            subtitle = "Added to bucket list"
        } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!){
            subtitle = "Already been here"
        }
        addAnnotationWithTitle(title: "\(place.name)", subtitle: subtitle, loc: WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))   )
        
        print("Place name: \(place.name)")
        print("Place location: \(place.coordinate)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.theViewC?.clearAnnotations()
        }) }
        
        else if destinationDecidedResultBool == true {
            //ADD ANNOTATION WITH CREATE TRIP BUTTON
            let a = MaplyAnnotation()
            
            let destinationDecidedButtonAnnotation = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
            destinationDecidedButtonAnnotation.setTitle("Plan trip to \(place.name)", for: .normal)
            destinationDecidedButtonAnnotation.sizeToFit()
            destinationDecidedButtonAnnotation.setTitleColor(UIColor.white, for: .normal)
            destinationDecidedButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
            let currentSize = destinationDecidedButtonAnnotation.titleLabel?.font.pointSize
            destinationDecidedButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: currentSize! - 1.5)
            destinationDecidedButtonAnnotation.backgroundColor = UIColor(red: 79/255, green: 146/255, blue: 255/255, alpha: 1)
            destinationDecidedButtonAnnotation.layer.cornerRadius = destinationDecidedButtonAnnotation.frame.height / 2
            destinationDecidedButtonAnnotation.titleLabel?.textAlignment = .center
            destinationDecidedButtonAnnotation.addTarget(self, action: #selector(self.bucketListButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let cancelButtonAnnotation = UIButton(frame: CGRect(x: 0, y: destinationDecidedButtonAnnotation.frame.height + 5, width: destinationDecidedButtonAnnotation.frame.width, height: 15))
            cancelButtonAnnotation.setTitle("Cancel", for: .normal)
            cancelButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            cancelButtonAnnotation.setTitleColor(UIColor.lightGray, for: .normal)
            cancelButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
            cancelButtonAnnotation.titleLabel?.textAlignment = .justified
            cancelButtonAnnotation.addTarget(self, action: #selector(self.cancelButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let frameForAnnotationContentView = CGRect(x: 0, y: 0, width: destinationDecidedButtonAnnotation.frame.width, height: destinationDecidedButtonAnnotation.frame.height + cancelButtonAnnotation.frame.height + 5)
            let annotationContentView = UIView(frame: frameForAnnotationContentView)
            annotationContentView.addSubview(destinationDecidedButtonAnnotation)
            annotationContentView.addSubview(cancelButtonAnnotation)
            
            a.contentView = annotationContentView
            theViewC?.addAnnotation(a, forPoint: WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude)), offset: CGPoint.zero)
            globeViewC?.keepNorthUp = true
            globeViewC?.animate(toPosition: WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude)), onScreen: (theViewC?.view.center)!, time: 1)
            globeViewC?.keepNorthUp = false
        }
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
