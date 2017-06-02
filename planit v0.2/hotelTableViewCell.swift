//
//  hotelTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps


class hotelTableViewCell: UITableViewCell, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var defaultStackView: UIStackView!
    @IBOutlet weak var expandedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet private weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var amenitiesButton: UIButton!
    @IBOutlet weak var whiteLine: UIImageView!
    @IBOutlet weak var expandedViewLabelOne: UILabel!
    @IBOutlet weak var expandedViewLabelTwo: UILabel!
    @IBOutlet weak var cancellationPolicyLabel: UILabel!
    
    var googleMaps: GMSMapView!
    var camera = GMSCameraPosition()
    var hotelReviewsTableView : UITableView?
    var reviewsArray : [String] = [String("I loved this hotel! Would highly recommend!"), String("Fantastic service and pillowtop mattresses"),  String("This trip was perfect. My children had a blast at the beautiful pool all day and my husband and I were able to escape to the spa where we got the best massages ever")]
    var distancesArray : [String] = [String("Airport: 10-15 minute drive"), String("Miami Seaquarium: 5 minute drive"),  String("Club Liv: 20 minute drive")]
    var amenitiesArray : [String] = [String("Free Wifi"), String("Fitness center"),  String("Pool"), String("Pet friendly")]
    var tableMode = String()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        self.googleMaps = GMSMapView.map(withFrame: CGRect(x: 0,y: 100, width: 187.5, height: 187.5), camera: camera)
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
        <D: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout>
        (dataSourceDelegate: D, forRow row: Int) {
        
        photosCollectionView.delegate = dataSourceDelegate
        photosCollectionView.dataSource = dataSourceDelegate
        photosCollectionView.tag = row
        photosCollectionView.reloadData()
    }

    //For expanding cells
    var showDetails = false {
        didSet {
            expandedViewHeightConstraint.priority = showDetails ? 250 : 999
            self.expandedViewPhotos()
        }
    }
    
    //For reviews tableview
    func setUpTable() {
        hotelReviewsTableView = UITableView(frame: CGRect.zero, style: .plain)
        hotelReviewsTableView?.delegate = self
        hotelReviewsTableView?.dataSource = self
        hotelReviewsTableView?.separatorColor = UIColor.white
        hotelReviewsTableView?.backgroundColor = UIColor.clear
        hotelReviewsTableView?.layer.backgroundColor = UIColor.clear.cgColor
        hotelReviewsTableView?.allowsSelection = false
        self.addSubview(hotelReviewsTableView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if tableMode == "reviews" {
            hotelReviewsTableView?.frame = CGRect(x: 0, y: 121, width: 322, height: 186)
        } else if tableMode == "amenities" {
            hotelReviewsTableView?.frame = CGRect(x: 0, y: 121, width: 140, height: 166)
        } else if tableMode == "distances" {
            hotelReviewsTableView?.frame = CGRect(x: 187.5, y: 121, width: 124.5, height: 166)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableMode == "reviews" {
            return reviewsArray.count
        } else if tableMode == "amenities" {
            return amenitiesArray.count
        }
        return distancesArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
        }
        
        if tableMode == "reviews" {
            cell?.textLabel?.text = reviewsArray[indexPath.row]
        } else if tableMode == "distances" {
            cell?.textLabel?.text = distancesArray[indexPath.row]
        } else if tableMode == "amenities" {
            cell?.textLabel?.text = amenitiesArray[indexPath.row]
        }
        
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }

    //MARK: custom functions for managing expanded view
    
    func expandedViewPhotos() {
        photosCollectionView.isHidden = false
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = true
        expandedViewLabelOne.isHidden = true
        expandedViewLabelTwo.isHidden = true
        cancellationPolicyLabel.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 6
                , y: 69, width: 55, height: 51)
        }
    }
    func expandedViewMap() {
        tableMode = "distances"
        photosCollectionView.isHidden = true
        googleMaps.isHidden = false
        hotelReviewsTableView?.isHidden = false
        hotelReviewsTableView?.frame = CGRect(x: 187.5, y: 121, width: 124.5, height: 166)
        hotelReviewsTableView?.reloadData()
        expandedViewLabelOne.isHidden = false
        expandedViewLabelOne.frame = CGRect(x: 197.5, y: 101, width: 125, height: 21)
        expandedViewLabelOne.text = "Distance to..."
        expandedViewLabelTwo.isHidden = true
        cancellationPolicyLabel.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 90, y: 69, width: 55, height: 51)
        }
    }
    func expandedViewReviews() {
        tableMode = "reviews"
        photosCollectionView.isHidden = true
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = false
        hotelReviewsTableView?.frame = CGRect(x: 0, y: 121, width: 322, height: 166)
        hotelReviewsTableView?.reloadData()
        expandedViewLabelOne.isHidden = false
        expandedViewLabelOne.frame = CGRect(x: 10, y: 101, width: 125, height: 21)
        expandedViewLabelOne.text = "Reviews"
        expandedViewLabelTwo.isHidden = true
        cancellationPolicyLabel.isHidden = true
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 174, y: 69, width: 55, height: 51)
        }
    }
    func expandedViewAmenities() {
        tableMode = "amenities"
        photosCollectionView.isHidden = true
        googleMaps.isHidden = true
        hotelReviewsTableView?.isHidden = false
        hotelReviewsTableView?.frame = CGRect(x: 0, y: 121, width: 124.5, height: 166)
        hotelReviewsTableView?.reloadData()
        expandedViewLabelOne.isHidden = false
        expandedViewLabelOne.frame = CGRect(x: 170, y: 101, width: 175, height: 21)
        expandedViewLabelOne.text = "Cancellation Policy"
        expandedViewLabelTwo.isHidden = false
        expandedViewLabelTwo.frame = CGRect(x: 10, y: 101, width: 150, height: 21)
        expandedViewLabelTwo.text = "Amenities"
        cancellationPolicyLabel.isHidden = false
        cancellationPolicyLabel.text = "Free cancellation up to 24 hours before your stay."
        cancellationPolicyLabel.numberOfLines = 0
        cancellationPolicyLabel.sizeToFit()
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 260, y: 69, width: 55, height: 51)
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
