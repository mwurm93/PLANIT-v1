//
//  instructionsView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/8/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class instructionsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //Class vars
    var instructionsCollectionView: UICollectionView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
        setUpCollectionView()
    }
    
    func setup() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        instructionsCollectionView?.frame = CGRect(x: 0, y: 46, width: 375, height: 170)
    }
    
    
    func setUpCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 65)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 245, height: 159)
        layout.minimumLineSpacing = 50
        
        instructionsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        instructionsCollectionView?.delegate = self
        instructionsCollectionView?.dataSource = self
        instructionsCollectionView?.showsHorizontalScrollIndicator = false
//        instructionsCollectionView?.isPagingEnabled = true
        instructionsCollectionView?.register(instructionsCollectionViewCell.self, forCellWithReuseIdentifier: "instructionsCollectionViewCell")
        instructionsCollectionView?.backgroundColor = UIColor.clear
        self.addSubview(instructionsCollectionView!)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "instructionsCollectionViewCell", for: indexPath) as! instructionsCollectionViewCell
        cell.addViews()
        
        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? NSNumber()
        
        var whiteInstructionIndex = Int()
        if lastVC == "newTrip" && bookingStatus == 0 {
            whiteInstructionIndex = 0
        } else if lastVC == "swiping" && bookingStatus == 0 {
            whiteInstructionIndex = 1
        } else if lastVC == "ranking"  && bookingStatus == 0 {
            whiteInstructionIndex = 2
        } else if lastVC == "flightSearch"  && bookingStatus == 0 {
            whiteInstructionIndex = 3
        } else if lastVC == "flightResults"  && bookingStatus == 0 {
            whiteInstructionIndex = 4
        } else if lastVC == "hotelResults"  && bookingStatus == 0 {
            whiteInstructionIndex = 5
        } else if lastVC == "booking"  && bookingStatus == 0 {
            whiteInstructionIndex = 6
        } else if bookingStatus == 1{
            whiteInstructionIndex = 7
        } else {
            whiteInstructionIndex = 0
        }

        if indexPath.item == 0 {
            cell.instructionsLabel.text = "Add your dates, home airport, and travel mates!"
        } else if indexPath.item == 1 {
            cell.instructionsLabel.text = "Swipe to discover where you might want to go, and invite your friends to do the same!"
        } else if indexPath.item == 2 {
            let hamburgerAttachment = NSTextAttachment()
            hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger")
            hamburgerAttachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 11)
            let changeAttachment = NSTextAttachment()
            changeAttachment.image = #imageLiteral(resourceName: "changeFlight")
            changeAttachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
            let changeHotelAttachment = NSTextAttachment()
            changeHotelAttachment.image = #imageLiteral(resourceName: "changeHotel")
            changeHotelAttachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
            
            if indexPath.item < whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_green")
                changeAttachment.image = #imageLiteral(resourceName: "changeFlight_green")
                changeHotelAttachment.image = #imageLiteral(resourceName: "changeHotel_green")
            } else if indexPath.item > whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_grey")
                changeAttachment.image = #imageLiteral(resourceName: "changeFlight_grey")
                changeHotelAttachment.image = #imageLiteral(resourceName: "changeHotel_grey")
            }
            
            let stringForLabel = NSMutableAttributedString(string: "Price out your group's options! Tap ")
            let attachment1 = NSAttributedString(attachment: changeAttachment)
            let attachment2 = NSAttributedString(attachment: hamburgerAttachment)
            let attachment3 = NSAttributedString(attachment: changeHotelAttachment)
            stringForLabel.append(attachment1)
            stringForLabel.append(NSAttributedString(string:" to look at flights, "))
            stringForLabel.append(attachment3)
            stringForLabel.append(NSAttributedString(string:" to look at hotels, and drag the "))
            stringForLabel.append(attachment2)
            stringForLabel.append(NSAttributedString(string: " to change your group's top trip"))
            cell.instructionsLabel.attributedText = stringForLabel
        } else if indexPath.item == 3 {
            cell.instructionsLabel.text = "Search flights to this destination to price it out"
        } else if indexPath.item == 4 {
            let hamburgerAttachment = NSTextAttachment()
            hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger")
            hamburgerAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
            if indexPath.item < whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_green")
            } else if indexPath.item > whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_grey")
            }
            let stringForLabel = NSMutableAttributedString(string: "Explore your flight options drag the ")
            let attachment1 = NSAttributedString(attachment: hamburgerAttachment)
            stringForLabel.append(attachment1)
            stringForLabel.append(NSAttributedString(string: " to change your flight"))
            cell.instructionsLabel.attributedText = stringForLabel
        } else if indexPath.item == 5 {
            let hamburgerAttachment = NSTextAttachment()
            hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger")
            hamburgerAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
            if indexPath.item < whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_green")
            } else if indexPath.item > whiteInstructionIndex {
                hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_grey")
            }
            let stringForLabel = NSMutableAttributedString(string: "Explore your hotel options and drag the ")
            let attachment1 = NSAttributedString(attachment: hamburgerAttachment)
            stringForLabel.append(attachment1)
            stringForLabel.append(NSAttributedString(string: " to change your group's hotel"))
            cell.instructionsLabel.attributedText = stringForLabel
        } else if indexPath.item == 6 {
        cell.instructionsLabel.text = "Time to book! You only pay for your share of the accomodation, and can automatically cancel your reservation if others don't commit in 24 hours"
        }
        
        
        if indexPath.item < whiteInstructionIndex {
            cell.instructionsLabel.textColor = UIColor.green
            cell.instructionsOutlineView.layer.borderColor = UIColor.green.cgColor
            cell.checkmarkImageView.isHidden = false
        } else if indexPath.item == whiteInstructionIndex {
            cell.instructionsLabel.textColor = UIColor.white
            cell.instructionsOutlineView.layer.borderColor = UIColor.white.cgColor
            cell.checkmarkImageView.isHidden = true
        } else if indexPath.item > whiteInstructionIndex {
            cell.instructionsLabel.textColor = UIColor.gray
            cell.instructionsOutlineView.layer.borderColor = UIColor.gray.cgColor
            cell.checkmarkImageView.isHidden = true
        }

        return cell
    }
}
