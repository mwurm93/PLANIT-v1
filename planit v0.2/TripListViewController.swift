//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces

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
    
    // Outlets for instructions
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var destinationDecidedControlView: UIView!
    @IBOutlet weak var destinationDecidedControl: UISegmentedControl!
    
    var theViewC: MaplyBaseViewController?
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white
    private var vectorDict: [String: AnyObject]?
    private var useLocalTiles = false
    var selectionColor = UIColor()
    private var selectedVectorFillDict: [String: AnyObject]?
    private var selectedVectorOutlineDict: [String: AnyObject]?
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

    
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    
    let sectionTitles = ["Still in the works...", "Booked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GOOGLE PLACES SEARCH
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.isTranslucent = true
        searchController?.searchBar.layer.cornerRadius = 5
        searchController?.searchBar.barStyle = .default
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.setShowsCancelButton(false, animated: false)
        searchController?.searchBar.delegate = self
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
        view.insertSubview(subView, belowSubview: popupBackgroundView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        handleModeButtonImages()
        
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
        
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.isHidden = true
        popupBackgroundView.isUserInteractionEnabled = true
        self.popupBackgroundView.addGestureRecognizer(tap)
        
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
            instructionsTitleLabel.isHidden = false
        
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
            instructionsTitleLabel.isHidden = true
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissPopup(touch: UITapGestureRecognizer) {
            popupBackgroundView.isHidden = true
            destinationDecidedControlView.isHidden = true
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
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 71, width: 196, height: 135)
    }
    
    @IBAction func destinationDecidedControlValueChanged(_ sender: Any) {
        if destinationDecidedControl.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "addTripDestinationUndecided", sender: self)
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
                    cell.existingTripTableViewImage.image = #imageLiteral(resourceName: "NYE")
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

        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                DataContainerSingleton.sharedDataContainer.currenttrip = trip
            }
        }
        
//        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
//        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? NSNumber()

//        if finishedEnteringPreferencesStatus == "Name_Contacts_Rooms" && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToCalendar", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Calendar"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToDestination", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Destination"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToBudget", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Budget"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToActivities", sender: self)
//        } else if (finishedEnteringPreferencesStatus == "Activities" || finishedEnteringPreferencesStatus == "Swiping" || finishedEnteringPreferencesStatus == "Ranking")  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "FinishedExistingTripsToUnbookedSummary", sender: self)
//        } else {
            self.performSegue(withIdentifier: "unfinishedExistingTripsToSwiping", sender: self)
//        }
        
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
        }
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
                        instructionsTitleLabel.isHidden = false
                        
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
        return "👋🏼"
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
        
        let globeViewC = theViewC as? WhirlyGlobeViewController
        
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
                    return sphere
                }
                let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
                    let cylinder = MaplyShapeCylinder()
                    cylinder.baseCenter = location
                    cylinder.baseHeight = 0
                    cylinder.radius = 0.003
                    cylinder.height = 0.015
                    cylinder.selectable = true
                    return cylinder
                }
                
                self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: selectionColor])
                self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)])
                
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
        theViewC?.animate(toPosition: loc, onScreen: (theViewC?.view.center)!, time: 0.5)
    }
    
    private func addCountries() {
        // handle this in another thread
        let queue = DispatchQueue.global()
        queue.async() {
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
                                                            kMaplyMinVis: 0.005,
                                                            kMaplyMaxVis: 0.6,
                                                            kMaplyTextColor: UIColor.darkGray,
                                ])
                        }
                    }
                    
                    attrs.setValue("tbd", forKey: "selectionStatus")
                    self.theViewC?.addVectors([wgVecObj], desc: self.vectorDict)
                }
            }
        }
    }
    
    func handleModeButtonImages() {
        if mode == "pin" {
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin"), for: .normal)
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket_grey"), for: .normal)
        } else if mode == "fill" {
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin_grey"), for: .normal)
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket"), for: .normal)
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
        // Do something with the selected place.
        mode = "pin"
        handleModeButtonImages()
        let pinLocationSphere = [WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))]
        let pinLocationCylinder = [WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))]
        // convert capitals into spheres. Let's do it functional!
        let pinTopSphere = pinLocationSphere.map { location -> MaplyShapeSphere in
            let sphere = MaplyShapeSphere()
            sphere.center = WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))
            sphere.radius = 0.007
            sphere.height = 0.022
            sphere.selectable = true
            return sphere
        }
        let pinCylinder = pinLocationCylinder.map { location -> MaplyShapeCylinder in
            let cylinder = MaplyShapeCylinder()
            cylinder.baseCenter = WGCoordinateMakeWithDegrees(Float(place.coordinate.longitude), Float(place.coordinate.latitude))
            cylinder.baseHeight = 0
            cylinder.radius = 0.003
            cylinder.height = 0.015
            cylinder.selectable = true
            return cylinder
        }
        
        self.theViewC?.addShapes(pinTopSphere, desc: [kMaplyColor: selectionColor])
        self.theViewC?.addShapes(pinCylinder, desc: [kMaplyColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.75)])
        
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
        })
        
        
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
