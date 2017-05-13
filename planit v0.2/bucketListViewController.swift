//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class bucketListViewController: UIViewController, WhirlyGlobeViewControllerDelegate  {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    
    private var theViewC: MaplyBaseViewController?
    private var selectedVectorFillDict: [String: AnyObject]?
    private var selectedVectorOutlineDict: [String: AnyObject]?
    private var vectorDict: [String: AnyObject]?
    private var selectionColor = UIColor()
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white
    private var useLocalTiles = false

    //MARK: Outlets
    @IBOutlet weak var bucketListButton: UIButton!
    @IBOutlet weak var beenThereButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // add the countries
        addCountries()
        
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
            layer.handleEdges = (globeViewC != nil)
            layer.coverPoles = (globeViewC != nil)
            layer.requireElev = false
            layer.waitLoad = false
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
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.5)
            globeViewC.keepNorthUp = false
        }
        

        vectorDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: false as AnyObject,
            kMaplyColor: UIColor.white,
            kMaplyVecWidth: 3.0 as AnyObject
        ]

        selectedVectorFillDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: true as AnyObject,
            kMaplyColor: UIColor.white,
            kMaplyVecWidth: 3.0 as AnyObject
        ]
        
        selectedVectorOutlineDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: false as AnyObject,
            kMaplyColor: UIColor.white,
            kMaplyVecWidth: 3.0 as AnyObject
        ]

        if let globeViewC = globeViewC {
            globeViewC.delegate = self
        }
    }

    private func handleSelection(selectedObject: NSObject) {
        
        if let selectedObject = selectedObject as? MaplyVectorObject {
            let loc = selectedObject.centroid()
            var subtitle = ""
            
            
            if selectionColor == UIColor(cgColor: bucketListButton.layer.backgroundColor!) {
            
                if selectedObject.attributes["selectionStatus"] as! String != "bucketList" {
                subtitle = "Added to bucket list"
                
                selectedVectorFillDict = [
                    kMaplyColor: UIColor(cgColor: bucketListButton.layer.backgroundColor!),
                    kMaplySelectable: true as AnyObject,
                    kMaplyFilled: true as AnyObject,
                    kMaplyVecWidth: 3.0 as AnyObject
                ]
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict)
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict)
                
                selectedObject.attributes.setValue("bucketList", forKey: "selectionStatus")
            } else {
                selectedVectorFillDict = [
                    kMaplySelectable: true as AnyObject,
                    kMaplyFilled: false as AnyObject,
                    kMaplyVecWidth: 3.0 as AnyObject
                ]
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict)
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict)
                
                selectedObject.attributes.setValue("tbd", forKey: "selectionStatus")
                }
                
            } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!) {
                if selectedObject.attributes["selectionStatus"] as! String != "bucketList" {
                subtitle = "Been there done that"
                
                selectedVectorFillDict = [
                    kMaplyColor: UIColor(cgColor: beenThereButton.layer.backgroundColor!),
                    kMaplySelectable: true as AnyObject,
                    kMaplyFilled: true as AnyObject,
                    kMaplyVecWidth: 3.0 as AnyObject
                ]
                
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict)
                self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict)
                
                selectedObject.attributes.setValue("beenThere", forKey: "selectionStatus")
                } else {
                    selectedVectorFillDict = [
                        kMaplySelectable: true as AnyObject,
                        kMaplyFilled: false as AnyObject,
                        kMaplyVecWidth: 3.0 as AnyObject
                    ]
                    self.theViewC?.addVectors([selectedObject], desc: selectedVectorFillDict)
                    self.theViewC?.addVectors([selectedObject], desc: selectedVectorOutlineDict)
                    
                    selectedObject.attributes.setValue("tbd", forKey: "selectionStatus")
                    
                }
            }
            
            
            addAnnotationWithTitle(title: selectedObject.userObject as! String, subtitle: subtitle, loc: loc)
        } else if let selectedObject = selectedObject as? MaplyScreenMarker {
            addAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObject.loc)
        }
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
        handleSelection(selectedObject: selectedObj)
    }
    
    private func addAnnotationWithTitle(title: String, subtitle: String, loc:MaplyCoordinate) {
        theViewC?.clearAnnotations()
        
        let a = MaplyAnnotation()
        a.title = title
        a.subTitle = subtitle
        
        theViewC?.addAnnotation(a, forPoint: loc, offset: CGPoint.zero)
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
                    }
                    
                    attrs.setValue("tbd", forKey: "selectionStatus")
                    self.theViewC?.addVectors([wgVecObj], desc: self.vectorDict)
                }
            }
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

}
