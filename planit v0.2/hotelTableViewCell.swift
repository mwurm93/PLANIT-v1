//
//  hotelTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps


class hotelTableViewCell: UITableViewCell, GMSMapViewDelegate,UITableViewDataSource,UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var defaultStackView: UIStackView!
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var expandedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet private weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var amenitiesButton: UIButton!
    @IBOutlet weak var whiteLine: UIImageView!
    
    var googleMaps: GMSMapView!
    var camera = GMSCameraPosition()
    var hotelReviewsTableView : UITableView?
    var reviewsArray : [String] = ["I loved this hotel!", "Fantastic service and pillowtop mattresses"]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        super.init(style: .default , reuseIdentifier: "hotelReviewTableViewCell")
        setUpTable()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTable()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpTable()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // For Google Map view
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
    
    // For Photos Collection View
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        photosCollectionView.delegate = dataSourceDelegate
        photosCollectionView.dataSource = dataSourceDelegate
        photosCollectionView.tag = row
        photosCollectionView.reloadData()
    }

    //For expanding cells
    var showDetails = false {
        didSet {
            expandedViewHeightConstraint.priority = showDetails ? 250 :999
        }
    }
    
    //For reviews tableview
    func setUpTable(){
        let hotelReviewsTableView = UITableView(frame: CGRect.zero, style: .plain)
        hotelReviewsTableView.delegate = self
        hotelReviewsTableView.dataSource = self
        hotelReviewsTableView.separatorColor = UIColor.white
        self.addSubview(hotelReviewsTableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hotelReviewsTableView?.frame = CGRect(x: 0, y: 101, width: 375, height: 186)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "hotelReviewTableViewCell", for: indexPath) as! hotelReviewTableViewCell
        
        cell.textLabel?.text = reviewsArray[indexPath.row]
        
        return cell
    }

    //MARK: custom functions for managing expanded view
    
    func expandedViewPhotos() {
        photosCollectionView.isHidden = false
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 33, y: 69, width: 55, height: 51)
        }
    }
    func expandedViewMap() {
        photosCollectionView.isHidden = true
        googleMaps.isHidden = false
        hotelReviewsTableView?.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 117, y: 69, width: 55, height: 51)
        }
    }
    func expandedViewReviews() {
        photosCollectionView.isHidden = true
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 201, y: 69, width: 55, height: 51)
        }
    }
    func expandedViewAmenities() {
        photosCollectionView.isHidden = true
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 285, y: 69, width: 55, height: 51)
        }
    }

    
    //MARK: actions
    @IBAction func photosButtonIsTouchedUpInside(_ sender: Any) {
        expandedViewPhotos()
    }
    @IBAction func mapButtonTouchedUpInside(_ sender: Any) {
        expandedViewMap()
    }
    @IBAction func reviewsButtonTouchedUpInside(_ sender: Any) {
        expandedViewReviews()
    }
    @IBAction func amenitiesButtonTouchedUpInside(_ sender: Any) {
        expandedViewAmenities()
    }
}
