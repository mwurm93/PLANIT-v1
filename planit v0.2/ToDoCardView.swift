//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CardView: UIView, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Class vars
    var topThingsToDoTableView: UITableView?
    var destinationPhotosCollectionView: UICollectionView?
    var destinationStockPhotos = [#imageLiteral(resourceName: "miami_1"),#imageLiteral(resourceName: "miami_2")]
    var topThingsToDoText = ["Vizcaya Museum and Gardens", "American Airlines Arena", "Wynwood Walls", "Boat tours","Zoological Wildlife Foundation"]
    
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
    }

    func setup() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;

        setUpTable()
        setUpCollectionView()
        
        let destinationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        //Add from data model
        destinationLabel.text = " Miami"
        destinationLabel.font = UIFont.boldSystemFont(ofSize: 31)
        destinationLabel.textColor = UIColor.white
        self.addSubview(destinationLabel)

        let averageWeatherLabel_High = UILabel(frame: CGRect(x: 0, y: 335 + 10, width: bounds.width, height: 23))
        averageWeatherLabel_High.text = " Average high in June: 83°F"
        averageWeatherLabel_High.font = UIFont.boldSystemFont(ofSize: 20)
        averageWeatherLabel_High.textColor = UIColor.white
        self.addSubview(averageWeatherLabel_High)

        let averageWeatherLabel_Low = UILabel(frame: CGRect(x: 0, y: averageWeatherLabel_High.frame.maxY + 5, width: bounds.width, height: 23))
        averageWeatherLabel_Low.text = " Average low in June: 70°F"
        averageWeatherLabel_Low.font = UIFont.boldSystemFont(ofSize: 20)
        averageWeatherLabel_Low.textColor = UIColor.white
        self.addSubview(averageWeatherLabel_Low)
    }
 
    func setUpTable() {
        topThingsToDoTableView = UITableView(frame: CGRect.zero, style: .grouped)
        topThingsToDoTableView?.delegate = self
        topThingsToDoTableView?.dataSource = self
        topThingsToDoTableView?.separatorColor = UIColor.white
        topThingsToDoTableView?.backgroundColor = UIColor.clear
        topThingsToDoTableView?.layer.backgroundColor = UIColor.clear.cgColor
        topThingsToDoTableView?.allowsSelection = false
        topThingsToDoTableView?.backgroundView = nil
        topThingsToDoTableView?.isOpaque = false
        self.addSubview(topThingsToDoTableView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topThingsToDoTableView?.frame = CGRect(x: 0, y: 150, width: 300, height: 186)
        var frame = self.topThingsToDoTableView?.frame
        frame?.size.height = 170
        self.topThingsToDoTableView?.frame = frame!
        
        destinationPhotosCollectionView?.frame = CGRect(x: 0, y: 0, width: 315, height: 150)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topThingsToDoText.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
        }
        
        cell?.textLabel?.text = topThingsToDoText[indexPath.row]
        
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = UIColor.clear
        cell?.layer.backgroundColor = UIColor.clear.cgColor
        
        return cell!
    }
    
    // Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top things to do"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 20, width: (topThingsToDoTableView?.bounds.size.width)!, height: 23))
        
        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = "Top things to do"
        header.addSubview(title)
        
        return header
    }
    
    func setUpCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 315, height: 150)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        destinationPhotosCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        destinationPhotosCollectionView?.layer.cornerRadius = 10
        destinationPhotosCollectionView?.delegate = self
        destinationPhotosCollectionView?.dataSource = self
        destinationPhotosCollectionView?.isPagingEnabled = true
        destinationPhotosCollectionView?.register(destinationPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "destinationPhotosCollectionViewCell")
        destinationPhotosCollectionView?.backgroundColor = UIColor.clear
        self.addSubview(destinationPhotosCollectionView!)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return destinationStockPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "destinationPhotosCollectionViewCell", for: indexPath) as! destinationPhotosCollectionViewCell
        cell.addViews()
        cell.destinationImageView.image = destinationStockPhotos[indexPath.item]
        
        return cell
    }

}
