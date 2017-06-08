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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 225, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let instructionsOutlineView: UIView = {
        let outlineView = UIView(frame: CGRect(x: 0, y: 0, width: 225, height: 100))
        outlineView.backgroundColor = UIColor.clear
        outlineView.layer.backgroundColor = UIColor.clear.cgColor
        outlineView.layer.cornerRadius = 10
        outlineView.layer.borderColor = UIColor.white.cgColor
        outlineView.layer.borderWidth = 3
        return outlineView
    }()
    
    func addViews() {
        self.addSubview(instructionsOutlineView)
        self.addSubview(instructionsLabel)
    }
}
