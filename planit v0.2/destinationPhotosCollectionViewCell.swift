//
//  destinationPhotosCollectionViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/1/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationPhotosCollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let destinationImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 315, height: 150))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func addViews() {
        self.addSubview(destinationImageView)
    }
}
