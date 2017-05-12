//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class bucketListViewController: UIViewController  {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    
    private var theViewC: MaplyBaseViewController?
    private var vectorDict: [String: AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        
        vectorDict = [
            kMaplyColor: UIColor.white,
            kMaplySelectable: true as AnyObject,
            kMaplyVecWidth: 4.0 as AnyObject]
        
        // add the countries
        addCountries()

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
                    // the admin tag from the country outline geojson has the country name ­ save
                    let attrs = wgVecObj.attributes
                    if let vecName = attrs.object(forKey: "ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                    }
                    
                    // add the outline to our view
                    let compObj = self.theViewC?.addVectors([wgVecObj], desc: self.vectorDict)
                    
                    // If you ever intend to remove these, keep track of the MaplyComponentObjects above.
                }
            }
        }
    }

}
