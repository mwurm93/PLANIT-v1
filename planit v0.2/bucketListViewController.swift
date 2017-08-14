//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase

class bucketListViewController: UIViewController, WhirlyGlobeViewControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    
    //Firebase
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    var theViewC: MaplyBaseViewController?
    private var selectedVectorFillDict: [String: AnyObject]?
    private var selectedVectorOutlineDict: [String: AnyObject]?
    private var vectorDict: [String: AnyObject]?
    var selectionColor = UIColor()
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white
    private var useLocalTiles = false
    
    var bucketListPinLocations = [[String: AnyObject]]()
    var beenTherePinLocations = [[String: AnyObject]]()
    var bucketListCountries = [String]()
    var beenThereCountries = [String]()
    
    //bucket list pins
    var AddedSphereComponentObjs = [MaplyComponentObject]()
    var AddedCylinderComponentObjs = [MaplyComponentObject]()
    var AddedSphereMaplyShapeObjs = [MaplyShape]()
    var AddedCylinderMaplyShapeObjs = [MaplyShape]()
    //been there pins
    var AddedSphereComponentObjs_been = [MaplyComponentObject]()
    var AddedCylinderComponentObjs_been = [MaplyComponentObject]()
    var AddedSphereMaplyShapeObjs_been = [MaplyShape]()
    var AddedCylinderMaplyShapeObjs_been = [MaplyShape]()
    
    var currentSelectedShape = [String: AnyObject]()

    //bucket list countries
    var AddedFillComponentObjs = [MaplyComponentObject]()
    var AddedOutlineComponentObjs = [MaplyComponentObject]()
    var AddedFillVectorObjs = [MaplyVectorObject]()
    var AddedOutlineVectorObjs = [MaplyVectorObject]()
    
    //been there countries
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
    
    //TravelPayours
    var geoLoader: AviasalesAirportsGeoSearchPerformer!


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
        
        // Create an empty globe and add it to the view
        theViewC = WhirlyGlobeViewController()
        self.view.addSubview(theViewC!.view)
        theViewC!.view.frame = self.view.bounds
        addChildViewController(theViewC!)
        self.view.sendSubview(toBack: theViewC!.view)
        self.view.sendSubview(toBack: backgroundBlurFilterView)
        self.view.sendSubview(toBack: backgroundView)
        
        globeViewC = theViewC as? WhirlyGlobeViewController
        
        handleModeButtonImages()
        
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
        
        //COPY
        //Load previously placed pins and countries
//        bucketListPinLocations = DataContainerSingleton.sharedDataContainer.bucketListPinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
//        beenTherePinLocations = DataContainerSingleton.sharedDataContainer.beenTherePinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
        bucketListCountries = DataContainerSingleton.sharedDataContainer.bucketListCountries ?? [String]()
        beenThereCountries = DataContainerSingleton.sharedDataContainer.beenThereCountries ?? [String]()

        addPins()

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
//                    let a = MaplyAnnotation()
//                    
//                    let addedToBuckedListLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
//                    addedToBuckedListLabel.text = "Added to bucket list"
//                    addedToBuckedListLabel.sizeToFit()
//                    addedToBuckedListLabel.textColor = UIColor.darkGray
//                    addedToBuckedListLabel.textAlignment = .center
//                    
//                    let destinationDecidedButtonAnnotation = UIButton(frame: CGRect(x: (addedToBuckedListLabel.frame.width / 2) - 75, y: addedToBuckedListLabel.frame.height + 5, width: 150, height: 20))
//                    destinationDecidedButtonAnnotation.setTitle("Plan trip here", for: .normal)
//                    destinationDecidedButtonAnnotation.sizeToFit()
//                    destinationDecidedButtonAnnotation.frame.origin.x = (addedToBuckedListLabel.frame.width / 2) - (destinationDecidedButtonAnnotation.frame.width / 2)
//                    destinationDecidedButtonAnnotation.setTitleColor(UIColor.white, for: .normal)
//                    destinationDecidedButtonAnnotation.setTitleColor(UIColor.lightGray, for: .highlighted)
//                    let currentSize = destinationDecidedButtonAnnotation.titleLabel?.font.pointSize
//                    destinationDecidedButtonAnnotation.titleLabel?.font = UIFont.systemFont(ofSize: currentSize! - 1.5)
//                    destinationDecidedButtonAnnotation.backgroundColor = UIColor(red: 79/255, green: 146/255, blue: 255/255, alpha: 1)
//                    destinationDecidedButtonAnnotation.layer.cornerRadius = destinationDecidedButtonAnnotation.frame.height / 2
//                    destinationDecidedButtonAnnotation.titleLabel?.textAlignment = .center
//                    destinationDecidedButtonAnnotation.addTarget(self, action: #selector(self.bucketListButtonAnnotationClicked(sender:)), for: UIControlEvents.touchUpInside)
//                    
//                    let frameForAnnotationContentView = CGRect(x: 0, y: 0, width: addedToBuckedListLabel.frame.width, height: destinationDecidedButtonAnnotation.frame.height + addedToBuckedListLabel.frame.height + 5 )
//                    let annotationContentView = UIView(frame: frameForAnnotationContentView)
//                    annotationContentView.addSubview(destinationDecidedButtonAnnotation)
//                    annotationContentView.addSubview(addedToBuckedListLabel)
//                    
//                    a.contentView = annotationContentView
//                    theViewC?.addAnnotation(a, forPoint: coord, offset: CGPoint.zero)
//                    globeViewC?.keepNorthUp = true
//                    globeViewC?.animate(toPosition: coord, onScreen: (theViewC?.view.center)!, time: 1)
//                    globeViewC?.keepNorthUp = false

                    
                } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!){
                    subtitle = "Already been here"
                    addAnnotationWithTitle(title: "Pin", subtitle: subtitle, loc: coord)
                }
                

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
            addPins()
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin"), for: .normal)
            pinModeButton.layer.shadowOpacity = 0.6
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket_grey"), for: .normal)
            fillModeButton.layer.shadowOpacity = 0.2
        } else if mode == "fill" {
            removeAllPinsFromView()
            pinModeButton.setImage(#imageLiteral(resourceName: "map pin_grey"), for: .normal)
            pinModeButton.layer.shadowOpacity = 0.2
            fillModeButton.setImage(#imageLiteral(resourceName: "paint bucket"), for: .normal)
            fillModeButton.layer.shadowOpacity = 0.6
        }
    }
    
    func removeAllPinsFromView() {
        var index = 0
        for _ in AddedSphereMaplyShapeObjs {
            theViewC?.remove(AddedCylinderComponentObjs[index])
            theViewC?.remove(AddedSphereComponentObjs[index])
            index += 1
        }
        index = 0
        for _ in AddedSphereMaplyShapeObjs_been {
            theViewC?.remove(AddedCylinderComponentObjs_been[index])
            theViewC?.remove(AddedSphereComponentObjs_been[index])
            index += 1
        }
        theViewC?.clearAnnotations()
    }
    
    func removeAllCountriesFromView() {
        var index = 0
        for _ in AddedFillComponentObjs {
            theViewC?.remove(AddedFillComponentObjs[index])
            theViewC?.remove(AddedOutlineComponentObjs[index])
            theViewC?.clearAnnotations()
            index += 1
        }
        index = 0
        for _ in AddedFillComponentObjs_been {
            theViewC?.remove(AddedFillComponentObjs_been[index])
            theViewC?.remove(AddedOutlineComponentObjs_been[index])
            theViewC?.clearAnnotations()
            index += 1
        }
    }

    //    func addAllCountriesToView() {
    //        var index = 0
    //        for _ in AddedFillComponentObjs {
    //            theViewC?.remove(AddedFillComponentObjs[index])
    //            theViewC?.remove(AddedOutlineComponentObjs[index])
    //            theViewC?.clearAnnotations()
    //            index += 1
    //        }
    //        index = 0
    //        for _ in AddedFillComponentObjs_been {
    //            theViewC?.remove(AddedFillComponentObjs_been[index])
    //            theViewC?.remove(AddedOutlineComponentObjs_been[index])
    //            theViewC?.clearAnnotations()
    //            index += 1
    //        }
    //
    //
    //        //COPY
    //        if self.bucketListCountries.count != 0 {
    //            if self.bucketListCountries.contains(vecName as! String) {
    //                if (vecName.description.characters.count) > 0 {
    //                    self.selectedVectorFillDict = [
    //                        kMaplyColor: UIColor(cgColor: self.bucketListButton.layer.backgroundColor!),
    //                        kMaplySelectable: true as AnyObject,
    //                        kMaplyFilled: true as AnyObject,
    //                        kMaplyVecWidth: 3.0 as AnyObject,
    //                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
    //                        kMaplySubdivEpsilon: 0.15 as AnyObject
    //                    ]
    //                    var AddedFillComponentObj = MaplyComponentObject()
    //                    var AddedOutlineComponentObj = MaplyComponentObject()
    //
    //                    attrs.setValue("bucketList", forKey: "selectionStatus")
    //
    //                    AddedFillComponentObj = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorFillDict))!
    //                    AddedOutlineComponentObj = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorOutlineDict))!
    //                    self.AddedFillComponentObjs.append(AddedFillComponentObj)
    //                    self.AddedOutlineComponentObjs.append(AddedOutlineComponentObj)
    //                    self.AddedFillVectorObjs.append(wgVecObj)
    //                    self.AddedOutlineVectorObjs.append(wgVecObj)
    //                    alphabeticalBucketListCountries.append(wgVecObj.userObject as! String)
    //                }
    //            }
    //        }
    //        if self.beenThereCountries.count != 0 {
    //            if self.beenThereCountries.contains(vecName as! String) {
    //                if (vecName.description.characters.count) > 0 {
    //                    self.selectedVectorFillDict = [
    //                        kMaplyColor: UIColor(cgColor: self.beenThereButton.layer.backgroundColor!),
    //                        kMaplySelectable: true as AnyObject,
    //                        kMaplyFilled: true as AnyObject,
    //                        kMaplyVecWidth: 3.0 as AnyObject,
    //                        kMaplySubdivType: kMaplySubdivGrid as AnyObject,
    //                        kMaplySubdivEpsilon: 0.15 as AnyObject
    //                    ]
    //                    var AddedFillComponentObj_been = MaplyComponentObject()
    //                    var AddedOutlineComponentObj_been = MaplyComponentObject()
    //
    //                    attrs.setValue("beenThere", forKey: "selectionStatus")
    //
    //                    AddedFillComponentObj_been = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorFillDict))!
    //                    AddedOutlineComponentObj_been = (self.theViewC?.addVectors([wgVecObj], desc: self.selectedVectorOutlineDict))!
    //                    self.AddedFillComponentObjs_been.append(AddedFillComponentObj_been)
    //                    self.AddedOutlineComponentObjs_been.append(AddedOutlineComponentObj_been)
    //                    self.AddedFillVectorObjs_been.append(wgVecObj)
    //                    self.AddedOutlineVectorObjs_been.append(wgVecObj)
    //                    alphabeticalBeenThereCountries.append(wgVecObj.userObject as! String)
    //                }
    //            }
    //        }
    //
    //    }
    
    
    private func addPins() {
        
        if mode == "pin" {
            bucketListPinLocations = DataContainerSingleton.sharedDataContainer.bucketListPinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
            beenTherePinLocations = DataContainerSingleton.sharedDataContainer.beenTherePinLocations as? [[String : AnyObject]] ?? [[String : AnyObject]]()
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
        theViewC?.clearAnnotations()
    }
    func bucketListButtonAnnotationClicked(sender:UIButton) {
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
        } else {
            DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1

        }
        
        
        
        
        //Travelpayouts airport search
        geoLoader = AviasalesAirportsGeoSearchPerformer(delegate: self)
        
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        let selectedSphere = currentSelectedShape["selectedShapeLocation"] as! MaplyCoordinate
        let latitudeInDegrees = Double(selectedSphere.y) * 180 / Double.pi
        let longitudeInDegrees = Double(selectedSphere.x) * 180 / Double.pi
        
//        if destinationsForTrip.count > destinationsForTripDictArray.count {
            destinationsForTripDictArray.append(["latitude": latitudeInDegrees as NSNumber])
//        }
//        else {
//            destinationsForTripDictArray[indexOfDestinationBeingPlanned]["latitude"] = place.coordinate.latitude as NSNumber
//        }
        destinationsForTripDictArray[indexOfDestinationBeingPlanned]["longitude"] = longitudeInDegrees as NSNumber
        SavedPreferencesForTrip["destinationsForTripDictArray"] = destinationsForTripDictArray
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

        geoLoader?.searchAirportsNearLatitude(latitudeInDegrees, longitude: longitudeInDegrees)
        
        
        let location = CLLocation(latitude: latitudeInDegrees, longitude: longitudeInDegrees)
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
            
            
            
            
            
            
            let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
            var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
            var destinationsForTripStates = (SavedPreferencesForTrip["destinationsForTripStates"] as! [String])
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned == destinationsForTrip.count {
                //write new destination
                destinationsForTrip.append((city?.name)!)
                var destinationsForTripStatesToBeAppended = city?.countryName
//                    if destinationsForTripStatesToBeAppended == "United States" {
//                    for stateAbbreviationDict in stateAbbreviationsDict {
//                        if stateAbbreviationDict["State"] == place.addressComponents?[1].name {
//                            destinationsForTripStatesToBeAppended = ((place.addressComponents?[1].name)!)
//                        } else if stateAbbreviationDict["State"] == place.addressComponents?[2].name {
//                            destinationsForTripStatesToBeAppended = ((place.addressComponents?[2].name)!)
//                        }
//                    }
//                }
                destinationsForTripStates.append(destinationsForTripStatesToBeAppended!)
            }
            //        else if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            //            //over write
            //            destinationsForTrip[indexOfDestinationBeingPlanned] = (searchController?.searchBar.text)!
            //            if place.addressComponents?.count == 6 {
            //                destinationsForTripStates[indexOfDestinationBeingPlanned] = ((place.addressComponents?[5].name)!)
            //            } else if place.addressComponents?.count == 5 {
            //                destinationsForTripStates[indexOfDestinationBeingPlanned] = ((place.addressComponents?[4].name)!)
            //            } else if place.addressComponents?.count == 4 {
            //                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[3].name)!
            //            } else if place.addressComponents?.count == 3 {
            //                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[2].name)!
            //            } else if place.addressComponents?.count == 2 {
            //                destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[1].name)!
            //            }
            //            if destinationsForTripStates[indexOfDestinationBeingPlanned] == "United States" {
            //                for stateAbbreviationDict in stateAbbreviationsDict {
            //                    if stateAbbreviationDict["State"] == place.addressComponents?[1].name {
            //                        destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[1].name)!
            //                    } else if stateAbbreviationDict["State"] == place.addressComponents?[2].name {
            //                        destinationsForTripStates[indexOfDestinationBeingPlanned] = (place.addressComponents?[2].name)!
            //                    }
            //                }
            //            }
            //
            //        }
            //        else if indexOfDestinationBeingPlanned > destinationsForTrip.count {
            //            fatalError("indexOfDestinationBeingPlanned > destinationsForTrip.count in destinationsSwipedRightTableViewCell.swift")
            //        }
            SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
            SavedPreferencesForTrip["destinationsForTripStates"] = destinationsForTripStates
            
            self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        })
        
        
        self.performSegue(withIdentifier: "bucketListVCToTripVC", sender: self)
    }
    
    //MARK: Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "bucketListVCToTripVC" {
            let destination = segue.destination as? TripViewController
            
//            var NewOrAddedTripForSegue = Int()
//            
//            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//            var numberSavedTrips: Int?
//            if existing_trips == nil {
//                numberSavedTrips = 0
//                NewOrAddedTripForSegue = 1
//            } else {
//                numberSavedTrips = (existing_trips?.count)! - 1
//                if currentTripIndex <= numberSavedTrips! {
//                    NewOrAddedTripForSegue = 0
//                } else {
//                    let NewOrAddedTripForSegue =
            
//                }
//            }
            destination?.NewOrAddedTripFromSegue = 1
            destination?.isTripSpawnedFromBucketList = 1
            destination?.newChannelRef = channelRef
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

//Singleton saving methods
extension bucketListViewController {
    // MARK: SAVE TO SINGLETON
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Determine if new or added trip
        let isNewOrAddedTrip = determineIfNewOrAddedTrip()
        
        //Init preference vars for if new or added trip
        //Trip status
        var bookingStatus = NSNumber(value: 0)
        var progress = [NSNumber]()
        var lastVC = NSString()
        var timesViewed = NSDictionary()
        //New Trip VC
        var tripNameValue = NSString()
        var tripID = NSString()
        var contacts = [NSString]()
        var contactPhoneNumbers = [NSString]()
        var hotelRoomsValue =  [NSNumber]()
        var segmentLengthValue = [NSNumber]()
        var selectedDates = [NSDate]()
        var leftDateTimeArrays = NSDictionary()
        var rightDateTimeArrays = NSDictionary()
        var numberDestinations = NSNumber(value: 1)
        var nonSpecificDates = NSDictionary()
        var firebaseChannelKey = NSString()
        //Budget VC DEPRICATED
        var budgetValue = NSString()
        var expectedRoundtripFare = NSString()
        var expectedNightlyRate = NSString()
        //Suggested Destination VC DEPRICATED
        var decidedOnDestinationControlValue = NSString()
        var decidedOnDestinationValue = NSString()
        var suggestDestinationControlValue = NSString()
        var suggestedDestinationValue = NSString()
        
        var destinationsForTrip = [NSString]()
        var destinationsForTripStates = [NSString]()
        var travelDictionaryArray = [NSDictionary]()
        var placeToStayDictionaryArray = [NSDictionary]()
        var indexOfDestinationBeingPlanned = NSNumber(value: 0)
        var isInitiator = NSNumber(value: 1)
        var currentAssistantSubview = NSNumber(value: 0)
        var datesDestinationsDictionary = NSDictionary()
        var savedFlightTickets = [NSData]()
        var savedHotelItems = [NSData]()
        var lastFlightOpenInBrowser = NSDictionary()
        var lastHotelOpenInBrowser = NSDictionary()
        var assistantMode = NSString()
        var endingPoint = NSString()
        var destinationsForTripDictArray = [NSDictionary]()
        var endingPointDict = NSDictionary()
        var startingPointDict = NSDictionary()
        var JRSDKSearchInfo = NSData()
        var HDKSearchInfo = NSData()
        
        //Activities VC
        var selectedActivities = [NSString]()
        //Ranking VC
        var topTrips = [NSString]()
        var rankedPotentialTripsDictionary = [NSDictionary]()
        var rankedPotentialTripsDictionaryArrayIndex = NSNumber(value: 0)
        
        //Update preference vars if an existing trip
        if isNewOrAddedTrip == 0 {
            //Trip status
            bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
            progress = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "progress") as? [NSNumber] ?? [NSNumber]()
            lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
            timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
            //New Trip VC
            tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
            tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
            
            contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
            contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
            hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
            segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
            selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
            leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
            rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
            numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
            nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
            firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
            //Budget VC
            budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
            expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
            expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
            //Suggested Destination VC
            decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
            decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
            suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
            suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
            
            destinationsForTrip = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTrip") as? [NSString] ?? [NSString]()
            destinationsForTripStates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTripStates") as? [NSString] ?? [NSString]()
            travelDictionaryArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "travelDictionaryArray") as? [NSDictionary] ?? [NSDictionary]()
            placeToStayDictionaryArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "placeToStayDictionaryArray") as? [NSDictionary] ?? [NSDictionary]()
            indexOfDestinationBeingPlanned = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "indexOfDestinationBeingPlanned") as? NSNumber ?? NSNumber()
            isInitiator = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "isInitiator") as? NSNumber ?? NSNumber()
            currentAssistantSubview = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "currentAssistantSubview") as? NSNumber ?? NSNumber()
            datesDestinationsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "datesDestinationsDictionary") as? NSDictionary ?? NSDictionary()
            savedFlightTickets = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "savedFlightTickets") as? [NSData] ?? [NSData]()
            savedHotelItems = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "savedHotelItems") as? [NSData] ?? [NSData]()
            lastFlightOpenInBrowser = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastFlightOpenInBrowser") as? NSDictionary ?? NSDictionary()
            lastHotelOpenInBrowser = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastHotelOpenInBrowser") as? NSDictionary ?? NSDictionary()
            assistantMode = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "assistantMode") as? NSString ?? NSString()
            endingPoint = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "endingPoint") as? NSString ?? NSString()
            destinationsForTripDictArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTripDictArray") as? [NSDictionary] ?? [NSDictionary]()
            endingPointDict = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "endingPointDict") as? NSDictionary ?? NSDictionary()
            startingPointDict = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "startingPointDict") as? NSDictionary ?? NSDictionary()
            JRSDKSearchInfo = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "JRSDKSearchInfo") as? NSData ?? NSData()
            HDKSearchInfo = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "HDKSearchInfo") as? NSData ?? NSData()
            
            //Activities VC
            selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
            //Ranking VC
            topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
            rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
            rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
            
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"progress": progress, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed, "destinationsForTrip": destinationsForTrip,"travelDictionaryArray":travelDictionaryArray, "indexOfDestinationBeingPlanned": indexOfDestinationBeingPlanned,"isInitiator":isInitiator,"currentAssistantSubview":currentAssistantSubview,"datesDestinationsDictionary":datesDestinationsDictionary,"destinationsForTripStates":destinationsForTripStates,"savedFlightTickets":savedFlightTickets,"savedHotelItems":savedHotelItems,"lastFlightOpenInBrowser":lastFlightOpenInBrowser,"lastHotelOpenInBrowser":lastHotelOpenInBrowser,"assistantMode":assistantMode, "placeToStayDictionaryArray":placeToStayDictionaryArray,"endingPoint":endingPoint,"destinationsForTripDictArray":destinationsForTripDictArray,"startingPointDict":startingPointDict,"endingPointDict":endingPointDict,"JRSDKSearchInfo":JRSDKSearchInfo,"HDKSearchInfo":HDKSearchInfo] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
        
    }
    
    func determineIfNewOrAddedTrip() -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        var isNewOrAddedTrip: Int?
        if existing_trips == nil {
            numberSavedTrips = 0
            isNewOrAddedTrip = 1
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            if currentTripIndex <= numberSavedTrips! {
                isNewOrAddedTrip = 0
            } else {
                isNewOrAddedTrip = 1
            }
        }
        return isNewOrAddedTrip!
    }
    
    func saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            
        }
        
        //Case: first trip
        if existing_trips == nil {
            let firstTrip = [SavedPreferencesForTrip as NSDictionary]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = firstTrip
        }
            //Case: existing trip
        else if currentTripIndex <= numberSavedTrips!   {
            existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
            //Case: added trip, but not first trip
        else {
            existing_trips?.append(SavedPreferencesForTrip as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
    }

}

extension bucketListViewController: AviasalesAirportsGeoSearchPerformerDelegate {
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

