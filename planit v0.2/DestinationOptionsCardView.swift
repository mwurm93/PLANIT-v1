//
//  DestinationOptionsCardView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/19/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import UIColor_FlatColors
import Cartography

class DestinationOptionsCardView: UIView, UIGestureRecognizerDelegate {
    
//    , UITableViewDataSource, UITableViewDelegate
    
    //MARK: Outlets
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var detailedCardView: UIScrollView!
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    var button3: UIButton?
    var button4: UIButton?
    var button5: UIButton?
    var destinationsSwipedRightTableView : UITableView?
    
        //ZLSwipeableView vars
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var cardToLoadIndex = 0
    var loadCardsFromXib = true
    var isTrackingPanLocation = false
    var panGestureRecognizer = UIPanGestureRecognizer()
    var countSwipes = 0
    var totalDailySwipeAllotment = 6
    var moreSwipesAllotment = 3
        //City dict
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
//        self.layer.borderColor = UIColor.green.cgColor
//        self.layer.borderWidth = 2
        button1?.isHidden = true
        button2?.isHidden = true
        swipeableView.isHidden = true
        button4?.isHidden = true
        button5?.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 230)
        
        button1?.frame = CGRect(x: (bounds.size.width-200)/2, y: 490, width: 80, height: 80)
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.frame = CGRect(x: (bounds.size.width-200)/2+120, y: 490, width: 80, height: 80)
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        
        button3?.sizeToFit()
        button3?.frame.size.height = 30
        button3?.frame.size.width += 20
        button3?.frame.origin.x = (bounds.size.width - (button3?.frame.width)!) / 2
        button3?.frame.origin.y = 280
        button3?.layer.cornerRadius = (button3?.frame.height)! / 2
        
        button4?.sizeToFit()
        button4?.frame.size.height = 30
        button4?.frame.size.width += 20
        button4?.frame.origin.x = (bounds.size.width - (button4?.frame.width)!) / 2
        button4?.frame.origin.y = 230
        button4?.layer.cornerRadius = (button4?.frame.height)! / 2

        button5?.sizeToFit()
        button5?.frame.size.height = 30
        button5?.frame.size.width += 20
        button5?.frame.origin.x = (bounds.size.width - (button5?.frame.width)!) / 2
        button5?.frame.origin.y = 280
        button5?.layer.cornerRadius = (button5?.frame.height)! / 2
        
        swipeableView.nextView = {
            return self.nextCardView()
        }

        destinationsSwipedRightTableView?.frame = CGRect(x: 0, y: 150, width: 300, height: 186)
        
    }
        
    func addViews() {
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Cool, we’ve come up with some options for you!\n\nGive a thumbs up if you may be you interested, and a thumbs down if not."
        self.addSubview(questionLabel!)
        
        //Button3
        button3 = UIButton(type: .custom)
        button3?.frame = CGRect.zero
        button3?.setTitleColor(UIColor.white, for: .normal)
        button3?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button3?.setTitleColor(UIColor.white, for: .selected)
        button3?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button3?.layer.borderWidth = 1
        button3?.layer.borderColor = UIColor.white.cgColor
        button3?.layer.masksToBounds = true
        button3?.titleLabel?.numberOfLines = 0
        button3?.titleLabel?.textAlignment = .center
        button3?.setTitle("Got it", for: .normal)
        button3?.setTitle("Got it", for: .selected)
        button3?.translatesAutoresizingMaskIntoConstraints = false
        button3?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button3!)

        //Button4
        button4 = UIButton(type: .custom)
        button4?.frame = CGRect.zero
        button4?.setTitleColor(UIColor.white, for: .normal)
        button4?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button4?.setTitleColor(UIColor.white, for: .selected)
        button4?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button4?.layer.borderWidth = 1
        button4?.layer.borderColor = UIColor.white.cgColor
        button4?.layer.masksToBounds = true
        button4?.titleLabel?.numberOfLines = 0
        button4?.titleLabel?.textAlignment = .center
        button4?.setTitle("Choose a destination", for: .normal)
        button4?.setTitle("Choose a destination", for: .selected)
        button4?.translatesAutoresizingMaskIntoConstraints = false
        button4?.addTarget(self, action: #selector(self.chooseDestinationButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button4!)

        //Button5
        button5 = UIButton(type: .custom)
        button5?.frame = CGRect.zero
        button5?.setTitleColor(UIColor.white, for: .normal)
        button5?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button5?.setTitleColor(UIColor.white, for: .selected)
        button5?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button5?.layer.borderWidth = 1
        button5?.layer.borderColor = UIColor.white.cgColor
        button5?.layer.masksToBounds = true
        button5?.titleLabel?.numberOfLines = 0
        button5?.titleLabel?.textAlignment = .center
        button5?.setTitle("More options", for: .normal)
        button5?.setTitle("More options", for: .selected)
        button5?.translatesAutoresizingMaskIntoConstraints = false
        button5?.addTarget(self, action: #selector(self.moreOptionsButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button5!)
        
        //ZLSwipeableview
        swipeableView.allowedDirection = .Horizontal
        
        swipeableView.didStart = {view, location in
            //                print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            //                print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            //                print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            self.countSwipes += 1
            
            if self.totalDailySwipeAllotment - self.countSwipes > 8 {
                self.swipeableView.numberOfActiveView = 8
            } else {
                self.swipeableView.numberOfActiveView = UInt(self.totalDailySwipeAllotment - self.countSwipes)
            }
            if self.swipeableView.numberOfActiveView == 0 {
                
                let when = DispatchTime.now() + 0.4
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.questionLabel?.text = "Ready to choose one of the ones you liked as your destination?"
                    self.questionLabel?.isHidden = false
                    self.button4?.isHidden = false
                    self.button5?.isHidden = false
                    self.button1?.isHidden = true
                    self.button2?.isHidden = true
                }
            }
            
            let when = DispatchTime.now() + 0.8
            
            if direction == .Right {
                self.button2?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button2?.isSelected = false
                }
                
            }
            if direction == .Left {
                self.button1?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button1?.isSelected = false
                }
            }
        }
        swipeableView.didCancel = {view in
            //                print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            self.detailedCardView.isHidden = false
            self.bringSubview(toFront: self.detailedCardView)
            self.detailedCardView.alpha = 1
            self.detailedCardView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            let height = bounds.size.height
            self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! CardView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            contentView.layer.cornerRadius = 0
            contentView.layer.shadowOpacity = 0
            contentView.cardToLoad = self.countSwipes
            contentView.cardMode = "detailed"
            
            self.detailedCardView.addSubview(contentView)
            constrain(contentView, self.detailedCardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top + 70
                view1.width == self.detailedCardView.bounds.width
                view1.height == self.detailedCardView.bounds.height
            }
            self.swipeableView.isUserInteractionEnabled = false
            for subview in contentView.subviews {
                subview.frame.size.width = width
            }
        }
        swipeableView.didDisappear = { view in
            //                print("Did disappear swiping view")
        }
        
        constrain(swipeableView, self) { view1, view2 in
            view1.left == view2.left+30
            view1.right == view2.right-30
            view1.top == view2.top + 40
            view1.bottom == view2.bottom - 120
        }
        
        //Custom animation
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(Double.pi/180)
        }
        func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
            }, completion: nil)
        }
        swipeableView.numberOfActiveView = UInt(totalDailySwipeAllotment)
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
        
        self.loadCardsFromXib = true
        self.colorIndex = 0
        self.swipeableView.discardViews()
        self.swipeableView.loadViews()
        
        detailedCardView.isHidden = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(recognizer:)))
        panGestureRecognizer.delegate = self
        detailedCardView.addGestureRecognizer(panGestureRecognizer)
        detailedCardView.layer.cornerRadius = 15
        
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.layer.masksToBounds = true
        button1?.setImage(#imageLiteral(resourceName: "emptyX"), for: .normal)
        button1?.setImage(#imageLiteral(resourceName: "fullX"), for: .selected)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.xButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.layer.masksToBounds = true
        button2?.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
        button2?.setImage(#imageLiteral(resourceName: "fullHeart"), for: .selected)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.heartButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
        
    }
    
    //ZLFunctions
    func leftButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func upButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Up)
    }
    
    func rightButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func downButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Down)
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        if colorIndex >= colors.count {
            colorIndex = 0
        }
        
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            }
        }
        if cardToLoadIndex > rankedPotentialTripsDictionary.count - 1 {
            cardToLoadIndex = 0
        }
        
        
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = colorForName(colors[colorIndex])
        colorIndex += 1
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! CardView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            contentView.cardToLoad = cardToLoadIndex
            contentView.cardMode = "card"
            cardView.addSubview(contentView)
            
            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
             let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
             let views = ["contentView": contentView, "cardView": cardView]
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
             */
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        cardToLoadIndex += 1
        return cardView
    }
    
    //Dismissing detailed card view
    public func panRecognized(recognizer:UIPanGestureRecognizer) {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        let dismissTriggerOffset = height/5
        
        if recognizer.state == .began && detailedCardView.contentOffset.y == 0 {
            recognizer.setTranslation(CGPoint.zero, in: detailedCardView)
            isTrackingPanLocation = true
        } else if recognizer.state == .cancelled || recognizer.state == .ended && isTrackingPanLocation {
            let panOffset = recognizer.translation(in: detailedCardView)
            if panOffset.y < dismissTriggerOffset {
                UIView.animate(withDuration: 0.4) {
                    self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                }
            }
            isTrackingPanLocation = false
        } else if recognizer.state != .ended && recognizer.state != .cancelled &&
            recognizer.state != .failed && isTrackingPanLocation {
            let panOffset = recognizer.translation(in: detailedCardView)
            if panOffset.y < 0 {
                isTrackingPanLocation = false
            } else if panOffset.y < dismissTriggerOffset {
                let panOffset = recognizer.translation(in: detailedCardView)
                self.detailedCardView.frame = CGRect(x: 0, y: panOffset.y, width: width, height: height)
            } else {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                swipeableView.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.detailedCardView.frame = self.swipeableView.frame
                    self.detailedCardView.alpha = 0.6}, completion: { (finished: Bool) in
                        self.detailedCardView.alpha = 0.0}
                )
            }
        } else {
            isTrackingPanLocation = false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer : UIGestureRecognizer)->Bool {
        return false
    }

    
    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
//    // MARK: Destination options tableview
//    func setUpTable() {
//        destinationsSwipedRightTableView = UITableView(frame: CGRect.zero, style: .grouped)
//        destinationsSwipedRightTableView?.delegate = self
//        destinationsSwipedRightTableView?.dataSource = self
//        destinationsSwipedRightTableView?.separatorColor = UIColor.white
//        destinationsSwipedRightTableView?.backgroundColor = UIColor.clear
//        destinationsSwipedRightTableView?.layer.backgroundColor = UIColor.clear.cgColor
//        destinationsSwipedRightTableView?.allowsSelection = false
//        destinationsSwipedRightTableView?.backgroundView = nil
//        destinationsSwipedRightTableView?.isOpaque = false
//        self.addSubview(destinationsSwipedRightTableView!)
//    }
//    
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var numberOfRows = 0
//        
//        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
//        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
//            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
//                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
//                    if let thisTripDestinationTopThingsToDo = thisTripDict["swipingStatus"] as? [String] {
//                        numberOfRows = thisTripDestinationTopThingsToDo.count
//                    }
//                }
//            }
//        }
//        
//        return numberOfRows
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        //Add destination label from data model
//        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
//        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
//            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
//                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
//                    if let thisTripDestination = thisTripDict["destination"] as? String {
//                        let destinationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
//                        destinationLabel.font = UIFont.boldSystemFont(ofSize: 31)
//                        destinationLabel.textColor = UIColor.white
//                        destinationLabel.text = " " + thisTripDestination
//                        self.addSubview(destinationLabel)
//                    }
//                }
//            }
//        }
//        
//        
//        
//        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
//        
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
//        }
//        
//        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
//            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
//                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
//                    if let thisTripDestinationTopThingsToDo = thisTripDict["topThingsToDo"] as? [String] {
//                        cell?.textLabel?.text = thisTripDestinationTopThingsToDo[indexPath.row]
//                    }
//                }
//            }
//        }
//        
//        cell?.textLabel?.textColor = UIColor.white
//        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
//        cell?.textLabel?.numberOfLines = 0
//        cell?.backgroundColor = UIColor.clear
//        cell?.layer.backgroundColor = UIColor.clear.cgColor
//        
//        return cell!
//    }
//    
//    // Section Header
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Destinations you liked"
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = UIView(frame: CGRect(x: 0, y: 20, width: (topThingsToDoTableView?.bounds.size.width)!, height: 23))
//        
//        let title = UILabel()
//        title.frame = header.frame
//        title.textAlignment = .left
//        title.font = UIFont.boldSystemFont(ofSize: 18)
//        title.textColor = UIColor.white
//        
//        //Add destination label from data model
//        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
//        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
//            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
//                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[cardToLoad] as? Dictionary<String, AnyObject> {
//                    if let thisTripDestination = thisTripDict["destination"] as? String {
//                        title.text = "Top things to do in \(thisTripDestination)"
//                        self.addSubview(title)
//                    }
//                }
//            }
//        }
//        header.addSubview(title)
//        
//        return header
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(25)
//    }
    
    // MARK: Sent events

    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
            questionLabel?.isHidden = true
            button3?.isHidden = true
            button1?.isHidden = false
            button2?.isHidden = false
            swipeableView.isHidden = false
        } else {
            sender.layer.borderWidth = 1
        }
    }
    
    func xButtonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender == button1 && sender.isSelected == true  {
            button2?.isSelected = false
        }
        leftButtonAction()
    }
    func heartButtonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender == button2 && sender.isSelected == true {
            button1?.isSelected = false
        }
        rightButtonAction()
    }
    
    func chooseDestinationButtonClicked(sender:UIButton) {
        let when = DispatchTime.now() + 0.15
        DispatchQueue.main.asyncAfter(deadline: when) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
        }
    }
    func moreOptionsButtonClicked(sender:UIButton) {
        questionLabel?.isHidden = true
        button3?.isHidden = true
        button1?.isHidden = false
        button2?.isHidden = false
        button4?.isHidden = true
        button5?.isHidden = true
        swipeableView.isHidden = false
        
        //ZLSwipeableview
        countSwipes = 0
        
        swipeableView.allowedDirection = .Horizontal
        
        swipeableView.didStart = {view, location in
            //                print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            //                print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            //                print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            self.countSwipes += 1
            
            if self.moreSwipesAllotment - self.countSwipes > 8 {
                self.swipeableView.numberOfActiveView = 8
            } else {
                self.swipeableView.numberOfActiveView = UInt(self.moreSwipesAllotment - self.countSwipes)
            }
            if self.swipeableView.numberOfActiveView == 0 {
                
                let when = DispatchTime.now() + 0.4
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.questionLabel?.text = "Ready to choose your favorite destination?"
                    self.questionLabel?.isHidden = false
                    self.button4?.isHidden = false
                    self.button5?.isHidden = false
                    self.button1?.isHidden = true
                    self.button2?.isHidden = true
                }
            }
            
            let when = DispatchTime.now() + 0.8
            
            if direction == .Right {
                self.button2?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button2?.isSelected = false
                }
            }
            if direction == .Left {
                self.button1?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button1?.isSelected = false
                }
            }
        }
        swipeableView.didCancel = {view in
            //                print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            self.detailedCardView.isHidden = false
            self.bringSubview(toFront: self.detailedCardView)
            self.detailedCardView.alpha = 1
            self.detailedCardView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            let height = bounds.size.height
            self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! CardView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            contentView.layer.cornerRadius = 0
            contentView.layer.shadowOpacity = 0
            contentView.cardToLoad = self.countSwipes
            contentView.cardMode = "detailed"
            
            self.detailedCardView.addSubview(contentView)
            constrain(contentView, self.detailedCardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top + 70
                view1.width == self.detailedCardView.bounds.width
                view1.height == self.detailedCardView.bounds.height
            }
            self.swipeableView.isUserInteractionEnabled = false
            for subview in contentView.subviews {
                subview.frame.size.width = width
            }
        }
        swipeableView.didDisappear = { view in
            //                print("Did disappear swiping view")
        }
        
        constrain(swipeableView, self) { view1, view2 in
            view1.left == view2.left+30
            view1.right == view2.right-30
            view1.top == view2.top + 40
            view1.bottom == view2.bottom - 120
        }
        
        //Custom animation
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(Double.pi/180)
        }
        func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
            }, completion: nil)
        }
        swipeableView.numberOfActiveView = UInt(moreSwipesAllotment)
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
        
        self.loadCardsFromXib = true
        self.colorIndex = 0
        self.swipeableView.discardViews()
        self.swipeableView.loadViews()
        
        detailedCardView.isHidden = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(recognizer:)))
        panGestureRecognizer.delegate = self
        detailedCardView.addGestureRecognizer(panGestureRecognizer)
        detailedCardView.layer.cornerRadius = 15
    
    }
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
        let timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
        let firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
        let rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }

}
