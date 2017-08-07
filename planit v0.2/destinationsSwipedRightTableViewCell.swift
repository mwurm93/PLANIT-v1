//
//  destinationsSwipedRightTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationsSwipedRightTableViewCell: UITableViewCell {
    
    // MARK: Outlets

    // MARK: Class vars
    var cellButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellButton = UIButton(frame: CGRect(x: 5, y: 5, width: 60, height: 30))
        cellButton.setTitle("title", for: UIControlState.normal)
        cellButton?.setTitleColor(UIColor.white, for: .normal)
        cellButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        cellButton?.layer.borderWidth = 1
        cellButton?.layer.borderColor = UIColor.white.cgColor
        cellButton?.layer.masksToBounds = true
        cellButton?.titleLabel?.numberOfLines = 0
        cellButton?.titleLabel?.textAlignment = .center
        cellButton?.translatesAutoresizingMaskIntoConstraints = false
        cellButton?.addTarget(self, action: #selector(self.chooseDestinationButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        addSubview(cellButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func chooseDestinationButtonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender, color: UIColor.white)
        }
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        if indexOfDestinationBeingPlanned == destinationsForTrip.count {
            //write new destination
            destinationsForTrip.append((cellButton.titleLabel?.text)!)
        } else if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            //over write
            destinationsForTrip[indexOfDestinationBeingPlanned] = (cellButton.titleLabel?.text)!
        } else if indexOfDestinationBeingPlanned > destinationsForTrip.count {
            fatalError("indexOfDestinationBeingPlanned > destinationsForTrip.count in destinationsSwipedRightTableViewCell.swift")
        }
        SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        
        let when = DispatchTime.now() + 0.3
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
        }
    }
}
