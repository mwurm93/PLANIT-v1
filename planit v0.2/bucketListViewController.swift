//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces

class bucketListViewController: UIViewController, WhirlyGlobeViewControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    
    var theViewC: MaplyBaseViewController?
    private var selectedVectorFillDict: [String: AnyObject]?
    private var selectedVectorOutlineDict: [String: AnyObject]?
    private var vectorDict: [String: AnyObject]?
    var selectionColor = UIColor()
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white
    private var useLocalTiles = false
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

    //MARK: Outlets
    @IBOutlet weak var bucketListButton: UIButton!
    @IBOutlet weak var beenThereButton: UIButton!
    @IBOutlet weak var fillModeButton: UIButton!
    @IBOutlet weak var pinModeButton: UIButton!
    @IBOutlet weak var tripsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let subView = UIView(frame: CGRect(x: (self.view.frame.maxX - 2/3 * self.view.frame.maxX)/2 - 19, y: 20.0, width: 2/3 * self.view.frame.maxX, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
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
        bucketListButton.layer.shadowOpacity = 0.3
        
        beenThereButton.layer.cornerRadius = 5
        beenThereButton.layer.borderColor = UIColor.white.cgColor
        beenThereButton.layer.borderWidth = 0
        beenThereButton.layer.shadowColor = UIColor.black.cgColor
        beenThereButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        beenThereButton.layer.shadowRadius = 2
        beenThereButton.layer.shadowOpacity = 0.3
        
        fillModeButton.layer.shadowColor = UIColor.black.cgColor
        fillModeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        fillModeButton.layer.shadowRadius = 2
        fillModeButton.layer.shadowOpacity = 0.5
        
        pinModeButton.layer.shadowColor = UIColor.black.cgColor
        pinModeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        pinModeButton.layer.shadowRadius = 2
        pinModeButton.layer.shadowOpacity = 0.5
        
        tripsButton.layer.shadowColor = UIColor.black.cgColor
        tripsButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        tripsButton.layer.shadowRadius = 2
        tripsButton.layer.shadowOpacity = 0.5
        
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        settingsButton.layer.shadowRadius = 2
        settingsButton.layer.shadowOpacity = 0.5
        
        handleModeButtonImages()
        
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
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = true
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
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-96.7970, 32.7767), time: 1)
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
                                                            kMaplyTextColor: UIColor.darkGray,
                                                            kMaplyMinVis: 0.005,
                                                            kMaplyMaxVis: 0.6
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
    
    //MARK: Actions
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
extension bucketListViewController: GMSAutocompleteResultsViewControllerDelegate {
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
