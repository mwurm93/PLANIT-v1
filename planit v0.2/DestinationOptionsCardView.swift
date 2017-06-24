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

class DestinationOptionsCardView: UIView, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    var destinationsSwipedRightTableView: UITableView?
    var destinationsSwipedRight = [String]()
    var destinationsSwipedLeft = [String]()
    
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
        destinationsSwipedRightTableView?.isHidden = true
        button5?.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDestinationButtonSelection), name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 230)
        if !(destinationsSwipedRightTableView?.isHidden)! {
            self.questionLabel?.frame.size.height = 50
        }
        
        button1?.frame = CGRect(x: (bounds.size.width-200)/2, y: 510, width: 80, height: 80)
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.frame = CGRect(x: (bounds.size.width-200)/2+120, y: 510, width: 80, height: 80)
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
        button5?.frame.origin.y = 400
        button5?.layer.cornerRadius = (button5?.frame.height)! / 2
        
        swipeableView.nextView = {
            return self.nextCardView()
        }

        destinationsSwipedRightTableView?.frame = CGRect(x: (bounds.size.width - 300) / 2, y: 100, width: 300, height: 286)
        
    }
        
    func addViews() {
        
        setUpTable()
        
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
        button3?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
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
        button4?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        button4?.layer.borderWidth = 1
        button4?.layer.borderColor = UIColor.white.cgColor
        button4?.layer.masksToBounds = true
        button4?.titleLabel?.numberOfLines = 0
        button4?.titleLabel?.textAlignment = .center
        button4?.setTitle("Choose a destination", for: .normal)
        button4?.setTitle("Choose a destination", for: .selected)
        button4?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button4!)

        //Button5
        button5 = UIButton(type: .custom)
        button5?.frame = CGRect.zero
        button5?.setTitleColor(UIColor.lightGray, for: .normal)
        button5?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button5?.setTitleColor(UIColor.darkGray, for: .highlighted)
        button5?.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
        button5?.setTitleColor(UIColor.darkGray, for: .selected)
        button5?.setBackgroundColor(color: UIColor.lightGray, forState: .selected)
        button5?.layer.borderWidth = 1
        button5?.layer.borderColor = UIColor.lightGray.cgColor
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
                    self.questionLabel?.text = "Ready to choose\na destination?"
                    self.questionLabel?.frame.size.height = 50
                    self.questionLabel?.isHidden = false
                    self.button4?.isHidden = true
                    self.destinationsSwipedRightTableView?.reloadData()
                    self.destinationsSwipedRightTableView?.isHidden = false
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
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
                    if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                        if var thisTripDict = rankedPotentialTripsDictionaryFromSingleton[self.countSwipes - 1] as? Dictionary<String, AnyObject> {
                            if let thisTripDestination = thisTripDict["destination"] as? String {
                                if !self.destinationsSwipedRight.contains(thisTripDestination) {
                                    self.destinationsSwipedRight.append(thisTripDestination)
                                    thisTripDict["swipingStatus"] = "right" as AnyObject
                                    self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                                }
                            }
                        }
                    }
                }
            }
            if direction == .Left {
                self.button1?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button1?.isSelected = false
                }
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
                    if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                        if var thisTripDict = rankedPotentialTripsDictionaryFromSingleton[self.countSwipes - 1] as? Dictionary<String, AnyObject> {
                            if let thisTripDestination = thisTripDict["destination"] as? String {
                                if !self.destinationsSwipedLeft.contains(thisTripDestination) {
                                    self.destinationsSwipedLeft.append(thisTripDestination)
                                    thisTripDict["swipingStatus"] = "left" as AnyObject
                                    self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                                }
                            }
                        }
                    }
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
                view1.top == view2.top
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
            view1.top == view2.top + 55
            view1.bottom == view2.bottom - 100
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
    
    // MARK: Destination options tableview
    func handleDestinationButtonSelection(){
        for buttonRow in 0 ... destinationsSwipedRight.count - 1 {
            let cell = destinationsSwipedRightTableView?.cellForRow(at: IndexPath(row: buttonRow, section: 0)) as! destinationsSwipedRightTableViewCell
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if cell.cellButton.isSelected && !(SavedPreferencesForTrip["destinationsForTrip"] as! [String]).contains((cell.cellButton.titleLabel?.text)!) {
                cell.cellButton.isSelected = false
                cell.cellButton.layer.borderWidth = 1
            }
        }
    }
    
    func setUpTable() {
        destinationsSwipedRightTableView = UITableView(frame: CGRect.zero, style: .grouped)
        destinationsSwipedRightTableView?.delegate = self
        destinationsSwipedRightTableView?.dataSource = self
        destinationsSwipedRightTableView?.separatorColor = UIColor.clear
        destinationsSwipedRightTableView?.backgroundColor = UIColor.clear
        destinationsSwipedRightTableView?.layer.backgroundColor = UIColor.clear.cgColor
        destinationsSwipedRightTableView?.allowsSelection = false
        destinationsSwipedRightTableView?.backgroundView = nil
        destinationsSwipedRightTableView?.isOpaque = false
        destinationsSwipedRightTableView?.register(destinationsSwipedRightTableViewCell.self, forCellReuseIdentifier: "destinationsSwipedRightTableViewCell")
        self.addSubview(destinationsSwipedRightTableView!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinationsSwipedRight.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destinationsSwipedRightTableViewCell") as! destinationsSwipedRightTableViewCell
        
        cell.cellButton.setTitle(destinationsSwipedRight[indexPath.row], for: .normal)
        cell.cellButton.setTitle(destinationsSwipedRight[indexPath.row], for: .selected)
        cell.cellButton.sizeToFit()
        cell.cellButton.frame.size.height = 30
        cell.cellButton.frame.size.width += 20
        cell.cellButton.frame.origin.x = tableView.frame.width / 2 - cell.cellButton.frame.width / 2
        cell.cellButton.frame.origin.y = 5
        cell.cellButton.layer.cornerRadius = (cell.cellButton.frame.height) / 2

        cell.backgroundColor = UIColor.clear
        cell.backgroundView = nil
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
    
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
    
    func moreOptionsButtonClicked(sender:UIButton) {
        for buttonRow in 0 ... destinationsSwipedRight.count - 1 {
            let cell = destinationsSwipedRightTableView?.cellForRow(at: IndexPath(row: buttonRow, section: 0)) as! destinationsSwipedRightTableViewCell
            if cell.cellButton.isSelected {
                cell.cellButton.isSelected = false
                cell.cellButton.layer.borderWidth = 1
            }
        }
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        if destinationsForTrip.count == 0 {
        } else {
            destinationsForTrip.remove(at: 0)            
        }
        SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        questionLabel?.isHidden = true
        button3?.isHidden = true
        button1?.isHidden = false
        button2?.isHidden = false
        button4?.isHidden = true
        destinationsSwipedRightTableView?.isHidden = true
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
                    self.questionLabel?.text = "Ready to choose\na destination?"
                    self.questionLabel?.frame.size.height = 50
                    self.questionLabel?.isHidden = false
                    self.button4?.isHidden = true
                    self.destinationsSwipedRightTableView?.reloadData()
                    self.destinationsSwipedRightTableView?.isHidden = false
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
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
                    if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                        if var thisTripDict = rankedPotentialTripsDictionaryFromSingleton[self.countSwipes - 1] as? Dictionary<String, AnyObject> {
                            if let thisTripDestination = thisTripDict["destination"] as? String {
                                if !self.destinationsSwipedRight.contains(thisTripDestination) {
                                    self.destinationsSwipedRight.append(thisTripDestination)
                                    thisTripDict["swipingStatus"] = "right" as AnyObject
                                    self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                                }
                            }
                        }
                    }
                }
            }
            if direction == .Left {
                self.button1?.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.button1?.isSelected = false
                }
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
                    if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                        if var thisTripDict = rankedPotentialTripsDictionaryFromSingleton[self.countSwipes - 1] as? Dictionary<String, AnyObject> {
                            if let thisTripDestination = thisTripDict["destination"] as? String {
                                if !self.destinationsSwipedLeft.contains(thisTripDestination) {
                                    self.destinationsSwipedLeft.append(thisTripDestination)
                                    thisTripDict["swipingStatus"] = "left" as AnyObject
                                    self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                                }
                            }
                        }
                    }
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
                view1.top == view2.top
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
            view1.top == view2.top + 55
            view1.bottom == view2.bottom - 100
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
}
