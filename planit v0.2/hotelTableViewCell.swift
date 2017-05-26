//
//  hotelTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps


class hotelTableViewCell: UITableViewCell, GMSMapViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var defaultStackView: UIStackView!
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var expandedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapButton: UIButton!
    
    var googleMaps: GMSMapView!
    var camera = GMSCameraPosition()
    
    func showHotelOnMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.7617, longitude: -80.1918, zoom: 12.0)
        self.googleMaps = GMSMapView.map(withFrame: CGRect(x: 0,y: 100, width: self.googleMapsView.frame.size.width, height: self.googleMapsView.frame.height), camera: camera)
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
        marker.title = "Miami"
        marker.snippet = "Florida"
        marker.map = self.googleMaps

        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.googleMaps.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
        
        self.addSubview(self.googleMaps)
        self.googleMaps.camera = camera
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    var showDetails = false {
        didSet {
            expandedViewHeightConstraint.priority = showDetails ? 250 :999
        }
    }

}
