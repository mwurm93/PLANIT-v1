//
//  instructionsCollectionViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/8/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class instructionsCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let instructionsLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 225, height: 105))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let instructionsOutlineView: UIView = {
        let outlineView = UIView(frame: CGRect(x: 0, y: 0, width: 245, height: 105))
        outlineView.backgroundColor = UIColor.clear
        outlineView.layer.backgroundColor = UIColor.clear.cgColor
        outlineView.layer.cornerRadius = 10
        outlineView.layer.borderWidth = 3
        return outlineView
    }()
    
    let checkmarkImageView: UIImageView = {
        let checkmarkIV = UIImageView(frame: CGRect(x: 230, y: -5, width: 25, height: 25))
        checkmarkIV.image = #imageLiteral(resourceName: "checkmark")
        return checkmarkIV
    }()

    
    func addViews() {
        self.addSubview(instructionsOutlineView)
        self.addSubview(instructionsLabel)
        self.addSubview(checkmarkImageView)

    }
}
