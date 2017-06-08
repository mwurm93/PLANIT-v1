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
        instructionsCollectionView?.frame = CGRect(x: 0, y: 10, width: 375, height: 147)
    }
    
    
    func setUpCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 225, height: 70)
        layout.minimumLineSpacing = 50
        
        instructionsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        instructionsCollectionView?.delegate = self
        instructionsCollectionView?.dataSource = self
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
        
        cell.instructionsLabel.text = "Swipe to discover where you might want to go, and invite your friends to do the same!"

        return cell
    }
}
