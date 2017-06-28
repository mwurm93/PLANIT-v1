//
//  destinationsDatesCollectionViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationsDatesCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var destination: UIButton!
    @IBOutlet weak var date: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
//    let instructionsTitle: UILabel = {
//        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 250, height: 35))
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.font = UIFont.boldSystemFont(ofSize: 22)
//        label.textColor = UIColor.white
//        label.adjustsFontSizeToFitWidth = true
//        return label
//    }()
//    
//    let instructionsLabel_1: UILabel = {
//        let label = UILabel(frame: CGRect(x: 10, y: 35, width: 250, height: 100))
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.textAlignment = .left
//        label.font = UIFont.systemFont(ofSize: 19)
//        label.adjustsFontSizeToFitWidth = true
//        return label
//    }()
//    
//    let instructionsLabel_2: UILabel = {
//        let label = UILabel(frame: CGRect(x: 10, y: 77, width: 250, height: 42))
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 19)
//        label.adjustsFontSizeToFitWidth = true
//        return label
//    }()
//    
//    
//    let instructionsOutlineView: UIView = {
//        let outlineView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 155))
//        outlineView.backgroundColor = UIColor.clear
//        outlineView.layer.backgroundColor = UIColor.clear.cgColor
//        outlineView.layer.cornerRadius = 10
//        outlineView.layer.borderWidth = 3
//        return outlineView
//    }()
//    
//    let checkmarkLabel: UILabel = {
//        let checkmarkIV = UILabel(frame: CGRect(x: 253, y: -10, width: 40, height: 40))
//        checkmarkIV.text = "✅"
//        checkmarkIV.font = UIFont.systemFont(ofSize: 30)
//        return checkmarkIV
//    }()
//    
//    
//    func addViews() {
//        self.addSubview(instructionsOutlineView)
//        self.addSubview(instructionsTitle)
//        self.addSubview(instructionsLabel_1)
//        self.addSubview(instructionsLabel_2)
//        self.addSubview(checkmarkLabel)
//        
//    }
}
