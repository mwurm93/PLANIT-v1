//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class bucketListViewController: UIViewController, WhirlyGlobeViewControllerDelegate, MaplyViewControllerDelegate  {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    
    private var theViewC: MaplyBaseViewController?
    private var loftedVectorFillDict: [String: AnyObject]?
    private var loftedVectorOutlineDict: [String: AnyObject]?
    private var vectorDict: [String: AnyObject]?
    private var selectionColor = UIColor.green
    private let onBucketListSelectionColor = UIColor.green
    private let alreadyGoneSelectionColor = UIColor.red
    private let tbdSelectionColor = UIColor.darkGray

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            kMaplyColor: UIColor.darkGray,
            kMaplyLoftedPolyHeight: 0.008 as AnyObject,
            kMaplyLoftedPolySide: false as AnyObject
        ]

        vectorDict = [
            kMaplySelectable: true as AnyObject,
            kMaplyFilled: false as AnyObject
        ]

        
        loftedVectorOutlineDict = [
            kMaplyColor: UIColor.white,
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
            if selectedObject.attributes.value(forKey: "bucketListColorStatus") == nil {
                
            }
            addAnnotationWithTitle(title: "selected", subtitle: selectedObject.userObject as! String, loc: loc)
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
                    self.theViewC?.addLoftedPolys(vectorsToAdd, key: nil, cache: nil, desc: self.loftedVectorFillDict, mode: MaplyThreadMode.any)
                    self.theViewC?.addLoftedPolys(vectorsToAdd, key: nil, cache: nil, desc: self.loftedVectorOutlineDict, mode: MaplyThreadMode.any)
                    self.theViewC?.addVectors(vectorsToAdd, desc: self.vectorDict)
        }
    }

}
