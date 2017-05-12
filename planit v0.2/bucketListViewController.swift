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
    private var loftedVectorFillDict: [String: AnyObject]?
    private var loftedVectorOutlineDict: [String: AnyObject]?
    private var vectorDict: [String: AnyObject]?
    private var selectionColor = UIColor()
    private let cachedGrayColor = UIColor.darkGray
    private let cachedWhiteColor = UIColor.white

    //MARK: Outlets
    @IBOutlet weak var TBDButton: UIButton!
    @IBOutlet weak var bucketListButton: UIButton!
    @IBOutlet weak var beenThereButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectionColor = UIColor(cgColor: bucketListButton.layer.backgroundColor!)
        
        TBDButton.layer.cornerRadius = 5
        TBDButton.layer.borderColor = UIColor.white.cgColor
        TBDButton.layer.borderWidth = 0
        TBDButton.layer.shadowColor = UIColor.black.cgColor
        TBDButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        TBDButton.layer.shadowRadius = 2
        TBDButton.layer.shadowOpacity = 0.3

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
        
        // start up over Madrid, center of the old-world
        if let globeViewC = globeViewC {
            globeViewC.height = 1.2
            globeViewC.keepNorthUp = true
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.5)
            globeViewC.keepNorthUp = false
        }
        
        loftedVectorFillDict = [
            kMaplyColor: cachedGrayColor,
            kMaplyLoftedPolyHeight: 0.008 as AnyObject,
            kMaplyLoftedPolySide: false as AnyObject
        ]

        vectorDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: false as AnyObject
        ]

        
        loftedVectorOutlineDict = [
            kMaplyColor: cachedWhiteColor,
            kMaplyLoftedPolyHeight: 0.009 as AnyObject,
            kMaplyLoftedPolyTop: false as AnyObject,
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
                subtitle = "Added to bucket list"
                
                loftedVectorFillDict = [
                    kMaplyColor: UIColor(cgColor: bucketListButton.layer.backgroundColor!),
                    kMaplyLoftedPolyHeight: 0.008 as AnyObject,
                    kMaplyLoftedPolySide: false as AnyObject
                ]
                self.theViewC?.remove([selectedObject], mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorFillDict, mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorOutlineDict, mode: MaplyThreadMode.any)
            } else if selectionColor == UIColor(cgColor: beenThereButton.layer.backgroundColor!) {
                subtitle = "Been there done that"
                
                loftedVectorFillDict = [
                    kMaplyColor: UIColor(cgColor: beenThereButton.layer.backgroundColor!),
                    kMaplyLoftedPolyHeight: 0.008 as AnyObject,
                    kMaplyLoftedPolySide: false as AnyObject
                ]
                self.theViewC?.remove([selectedObject], mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorFillDict, mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorOutlineDict, mode: MaplyThreadMode.any)
            } else if selectionColor == UIColor(cgColor: TBDButton.layer.backgroundColor!) {
                subtitle = "Maybe in another life"
                
                loftedVectorFillDict = [
                    kMaplyColor: UIColor(cgColor: TBDButton.layer.backgroundColor!),
                    kMaplyLoftedPolyHeight: 0.008 as AnyObject,
                    kMaplyLoftedPolySide: false as AnyObject
                ]
                self.theViewC?.remove([selectedObject], mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorFillDict, mode: MaplyThreadMode.any)
                self.theViewC?.addLoftedPolys([selectedObject], key: nil, cache: nil, desc: self.loftedVectorOutlineDict, mode: MaplyThreadMode.any)

            }
            addAnnotationWithTitle(title: selectedObject.userObject as! String, subtitle: subtitle, loc: loc)
        }
        else if let selectedObject = selectedObject as? MaplyScreenMarker {
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
            var vectorsToAdd = [AnyObject]()
            for outline in allOutlines {
                if let jsonData = NSData(contentsOfFile: outline),
                    let wgVecObj = MaplyVectorObject(fromGeoJSON: jsonData as Data) {
                    wgVecObj.selectable = true
                    // the admin tag from the country outline geojson has the country name ­ save
                    let attrs = wgVecObj.attributes
                    if let vecName = attrs.object(forKey: "ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                    }
                    vectorsToAdd.append(wgVecObj)
                    
                }
            }
                    // add the outline and fill to our view
            self.theViewC?.addVectors(vectorsToAdd, desc: self.vectorDict)

            self.theViewC?.addLoftedPolys(vectorsToAdd, key: nil, cache: nil, desc: self.loftedVectorFillDict, mode: MaplyThreadMode.any)
                    self.theViewC?.addLoftedPolys(vectorsToAdd, key: nil, cache: nil, desc: self.loftedVectorOutlineDict, mode: MaplyThreadMode.any)
        }
    }
    
    //MARK: Actions
    @IBAction func TBDButtonTouchedUpInside(_ sender: Any) {
        TBDButton.layer.borderWidth = 3
        bucketListButton.layer.borderWidth = 0
        beenThereButton.layer.borderWidth = 0
        selectionColor = UIColor(cgColor: TBDButton.layer.backgroundColor!)
        
    }
    
    @IBAction func bucketListButtonTouchedUpInside(_ sender: Any) {
        TBDButton.layer.borderWidth = 0
        bucketListButton.layer.borderWidth = 3
        beenThereButton.layer.borderWidth = 0
        selectionColor = UIColor(cgColor: bucketListButton.layer.backgroundColor!)
    }
    @IBAction func beenThereButtonTouchedUpInside(_ sender: Any) {
        TBDButton.layer.borderWidth = 0
        bucketListButton.layer.borderWidth = 0
        beenThereButton.layer.borderWidth = 3
        selectionColor = UIColor(cgColor: beenThereButton.layer.backgroundColor!)
    }

}
