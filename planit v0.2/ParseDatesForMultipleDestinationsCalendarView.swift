//
//  ParseDatesForMultipleDestinationsCalendarView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/5/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import JTAppleCalendar
import UIColor_FlatColors

class ParseDatesForMultipleDestinationsCalendarView: UIView, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    //Class UI object vars
    var questionLabel: UILabel?
    var formatter = DateFormatter()
    var leftDate: Date?
    var button1: UIButton?
    var destinationDaysTableView: UITableView?

    
    //Cache color vars
    static let transparentColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
    static let whiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
    static let transparentWhiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
    static let darkGrayColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
    static let blackColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
    var selectionColor = UIColor()
    var selectionColorTransparent = UIColor()
    var colors = ["Turquoise", "Peter River","Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Turquoise", "Green Sea", "Asbestos"]
    var colorIndex = 0

    //Clas data object vars
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    var travelDates = [Date]()
    var fromDestination = 0
    var toDestination = 1
    
    var tripDates: [Date]?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        //        self.layer.borderColor = UIColor.purple.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 520
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        calendarView?.frame = CGRect(x: 13, y: 250, width: 350, height: 250)
        calendarView?.cellSize = 50
        
        destinationDaysTableView?.frame = CGRect(x: (bounds.size.width - 300) / 2, y: 100, width: 300, height: 150)

        
    }
    
  
    
    func loadDates() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date]
        if destinationsForTrip.count > 0 {
            tripDates = selectedDatesValue
            calendarView.selectDates(tripDates!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            if (tripDates?.count)! > 0 {
                
            }
        }
        
    }
    func scrollToDate() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date]
        let scrollToDate = selectedDatesValue?[0]
        calendarView.scrollToDate(scrollToDate!, animateScroll: true)
    }
    func addViews() {
        setUpTable()
        
        //Question label
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Change trip dates", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "When do you want to travel from \(destinationsForTrip[fromDestination]) to \(destinationsForTrip[toDestination])?"
        fromDestination += 1
        toDestination += 1
        self.addSubview(questionLabel!)
        
        // Calendar header setup
        calendarView?.register(UINib(nibName: "monthHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "monthHeaderView")
        
        // Calendar setup delegate and datasource
        calendarView?.calendarDataSource = self
        calendarView?.calendarDelegate = self
        calendarView?.register(UINib(nibName: "CellView", bundle: nil), forCellWithReuseIdentifier: "CellView")
        calendarView?.allowsMultipleSelection  = true
        calendarView?.isRangeSelectionUsed = true
        calendarView?.minimumLineSpacing = 0
        calendarView?.minimumInteritemSpacing = 2
        calendarView?.scrollingMode = .none
        calendarView?.scrollDirection = .vertical
        
        selectionColor = colorForName(colors[colorIndex])
        selectionColorTransparent = selectionColor.withAlphaComponent(0.35)
        
        loadDates()
    }
    
    //Tableview
    func setUpTable() {
        destinationDaysTableView = UITableView(frame: CGRect.zero, style: .grouped)
        destinationDaysTableView?.delegate = self
        destinationDaysTableView?.dataSource = self
        destinationDaysTableView?.separatorColor = UIColor.clear
        destinationDaysTableView?.backgroundColor = UIColor.clear
        destinationDaysTableView?.layer.backgroundColor = UIColor.clear.cgColor
        destinationDaysTableView?.allowsSelection = false
        destinationDaysTableView?.backgroundView = nil
        destinationDaysTableView?.isOpaque = false
        destinationDaysTableView?.isEditing = true
        destinationDaysTableView?.register(destinationsSwipedRightTableViewCell.self, forCellReuseIdentifier: "destinationDaysTableViewCell")
        self.addSubview(destinationDaysTableView!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        
        return destinationsForTrip.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destinationDaysTableViewCell") as! destinationDaysTableViewCell

        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        
        cell.cellButton.setTitle(destinationsForTrip[indexPath.row], for: .normal)
//        cell.cellButton.setTitle(destinationsForTrip[indexPath.row], for: .selected)
        cell.cellButton.sizeToFit()
        cell.cellButton.frame.size.height = 30
        cell.cellButton.frame.size.width += 20
        cell.cellButton.frame.origin.x = tableView.frame.width / 2 - cell.cellButton.frame.width / 2
        cell.cellButton.frame.origin.y = 5
//        cell.cellButton.layer.cornerRadius = (cell.cellButton.frame.height) / 2
        
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = nil
        if indexPath.row == 0 {
            cell.layer.backgroundColor = ParseDatesForMultipleDestinationsCalendarView.transparentWhiteColor.cgColor
        } else {
            cell.layer.backgroundColor = colorForName(colors[indexPath.row - 1]).cgColor
        }
        
        
        //Change hamburger icon
        for view in cell.subviews as [UIView] {
            if type(of: view).description().range(of: "Reorder") != nil {
                for subview in view.subviews as! [UIImageView] {
                    if subview.isKind(of: UIImageView.self) {
                        subview.image = UIImage(named: "hamburger")
                        subview.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }

    
    // MARK: JTCalendarView Extension
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let endDate = formatter.date(from: "2018 12 31")
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate!,
            numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
        return false
    }
    
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        let myCustomCell = cell as? CellView
        
        switch cellState.selectedPosition() {
        case .full:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = DatesPickedOutCalendarView.transparentWhiteColor
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.whiteColor
            myCustomCell?.selectedView.layer.cornerRadius =  0
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
        default:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.whiteColor
            if !(cellState.isSelected) {
                myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.darkGrayColor
            }
        }
        if cellState.date < Date() {
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.darkGrayColor
        }
        
        if cellState.dateBelongsTo != .thisMonth  {
            myCustomCell?.dayLabel.textColor = UIColor(cgColor: DatesPickedOutCalendarView.transparentColor)
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            return
        }

        //HANDLE TRAVEL DATES
        if travelDates.count > 0 {
            for i in 0 ... travelDates.count - 1 {
                selectionColor = colorForName(colors[i])
                selectionColorTransparent = selectionColor.withAlphaComponent(0.35)
                if cellState.date > travelDates[i] {
                    myCustomCell?.middleConnector.layer.backgroundColor = selectionColorTransparent.cgColor
                    myCustomCell?.rightSideConnector.layer.backgroundColor = selectionColorTransparent.cgColor
                    myCustomCell?.leftSideConnector.layer.backgroundColor = selectionColorTransparent.cgColor
                    myCustomCell?.selectedView.layer.backgroundColor = selectionColor.cgColor
                } else if cellState.date == travelDates[i] {
                    myCustomCell?.selectedView.isHidden = true
                    myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.whiteColor
                    myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.blackColor.cgColor
                    myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
                    myCustomCell?.rightSideConnector.isHidden = false
                    myCustomCell?.rightSideConnector.layer.backgroundColor = selectionColorTransparent.cgColor
                    myCustomCell?.leftSideConnector.isHidden = false
                    
                    myCustomCell?.middleConnector.isHidden = true
                    
                    if i == 0 {
                        myCustomCell?.leftSideConnector.layer.backgroundColor = DatesPickedOutCalendarView.transparentWhiteColor
                    }
                }
            }
        }
        if cellState.selectedPosition() == .left {
            myCustomCell?.rightSideConnector.layer.backgroundColor = DatesPickedOutCalendarView.transparentWhiteColor
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let myCustomCell = calendarView?.dequeueReusableJTAppleCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        myCustomCell.dayLabel.text = cellState.text
        if cellState.dateBelongsTo == .previousMonthWithinBoundary || cellState.dateBelongsTo == .followingMonthWithinBoundary {
            myCustomCell.isSelected = false
        }
        
        handleSelection(cell: myCustomCell, cellState: cellState)
        
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
//        calendarView?.deselectDates(from: date)
////        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
////        if calendar == travelDaysCalendarView {
////            if travelDaysCalendarView.selectedDates.count > ((SavedPreferencesForTrip["destinationsForTrip"] as! [String]).count - 1) {
////                calendarView?.deselectAllDates(triggerSelectionDelegate: false)
////                calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
////            }
////            
////        } else if calendar == calendarView {
//            if leftDateTimeArrays.count >= 1 && rightDateTimeArrays.count >= 1 {
//                calendarView?.deselectAllDates(triggerSelectionDelegate: false)
//                rightDateTimeArrays.removeAllObjects()
//                leftDateTimeArrays.removeAllObjects()
//                calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
//            }
//            
//            //UNCOMMENT FOR TWO CLICK RANGE SELECTION
//            let leftKeys = leftDateTimeArrays.allKeys
//            let rightKeys = rightDateTimeArrays.allKeys
//            if leftKeys.count == 1 && rightKeys.count == 0 {
//                formatter.dateFormat = "MM/dd/yyyy"
//                let leftDate = formatter.date(from: leftKeys[0] as! String)
//                if date > leftDate! {
//                    calendarView?.selectDates(from: leftDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
//                } else {
//                    calendarView?.deselectAllDates(triggerSelectionDelegate: false)
//                    rightDateTimeArrays.removeAllObjects()
//                    leftDateTimeArrays.removeAllObjects()
//                    calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
//                }
//            }
//            
//            handleSelection(cell: cell, cellState: cellState)
//            
//            let selectedDates = calendarView?.selectedDates as! [NSDate]
//            // Create dictionary of selected dates and destinations
//            var datesDestinationsDictionary = [String:[Date]]()
//            datesDestinationsDictionary["destinationTBD"] = selectedDates as [Date]
//            getLengthOfSelectedAvailabilities()
//            //Update trip preferences in dictionary
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
//            SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
//            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            
//            mostRecentSelectedCellDate = date as NSDate
//            
//            let availableTimeOfDayInCell = ["Anytime"]
//            let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
//            
//            formatter.dateFormat = "MM/dd/yyyy"
//            
//            let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
//            if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
//                let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//            }
//            if cell?.selectedPosition() == .right {
//                let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//            }
//            
//            //        //Update trip preferences in dictionary
//            //        let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//            //        SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//            //        SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//            //
//            //        //Save
//            //        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
////        }
    }

    func parseTripDatesByTravelDates() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        for i in 0 ... destinationsForTrip.count - 2 {
            var segmentDates = [Date]()
            if i - 1 >= 0 {
                //second to (n - 1)th segment
                for tripDate in tripDates! {
                    if tripDate <= travelDates[i] && tripDate >= travelDates[i-1]{
                        segmentDates.append(tripDate)
                    }
                }
            } else {
                //first segment
                for tripDate in tripDates! {
                    if tripDate <= travelDates[i] {
                        segmentDates.append(tripDate)
                    }
                }
            }
            datesDestinationsDictionary[destinationsForTrip[i]] = segmentDates
        }
        //last segment
        var lastSegmentDates = [Date]()
        for tripDate in tripDates! {
            if tripDate >= travelDates[travelDates.count - 1] {
                lastSegmentDates.append(tripDate)
            }
        }
        datesDestinationsDictionary[destinationsForTrip[destinationsForTrip.count - 1]] = lastSegmentDates
        
        //Save
        SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {

        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        if (tripDates?.contains(date))! {
            if travelDates.count < destinationsForTrip.count - 1 {
                var isDeselectedDateBeforeOtherTravelDates = false
                for travelDate in travelDates {
                    if date <= travelDate {
                        isDeselectedDateBeforeOtherTravelDates = true
                    }
                }
                if !isDeselectedDateBeforeOtherTravelDates {
                    travelDates.append(date)
                } else {
                    travelDates.removeAll()
                    travelDates.append(date)
                    fromDestination = 0
                    toDestination = 1
                    questionLabel?.text = "When do you want to travel from \(destinationsForTrip[fromDestination]) to \(destinationsForTrip[toDestination])?"
                    fromDestination += 1
                    toDestination += 1
                }
            } else {
                travelDates.removeAll()
                travelDates.append(date)
                fromDestination = 0
                toDestination = 1
                questionLabel?.text = "When do you want to travel from \(destinationsForTrip[fromDestination]) to \(destinationsForTrip[toDestination])?"
                fromDestination += 1
                toDestination += 1
            }
        }
        calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        calendarView?.reloadDates(calendarView.selectedDates)
        
        if (destinationsForTrip.count - 1) >= toDestination {
        
            UIView.animate(withDuration: 1) {
                self.questionLabel?.text = "When do you want to travel from \(destinationsForTrip[self.fromDestination]) to \(destinationsForTrip[self.toDestination])?"
            }
            fromDestination += 1
            toDestination += 1
        } else {
            parseTripDatesByTravelDates()
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsComplete"), object: nil)
            }
        }
        
//        handleSelection(cell: cell, cellState: cellState)
//
//        handleSelection(cell: cell, cellState: cellState)
//        getLengthOfSelectedAvailabilities()
//        
//        if lengthOfAvailabilitySegmentsArray.count > 1 || (leftDates.count > 0 && rightDates.count > 0 && fullDates.count > 0) || fullDates.count > 1 {
//            rightDateTimeArrays.removeAllObjects()
//            leftDateTimeArrays.removeAllObjects()
//            lengthOfAvailabilitySegmentsArray.removeAll()
//            calendarView?.deselectAllDates(triggerSelectionDelegate: false)
//            return
//        }
//        
//        // Create array of selected dates
//        calendarView?.deselectDates(from: date, to: date, triggerSelectionDelegate: false)
//        let selectedDates = calendarView?.selectedDates as! [NSDate]
//        
//        if selectedDates.count > 0 {
//            
//            var leftMostDate: Date?
//            var rightMostDate: Date?
//            
//            for selectedDate in selectedDates {
//                if leftMostDate == nil {
//                    leftMostDate = selectedDate as Date
//                } else if leftMostDate! > selectedDate as Date {
//                    leftMostDate = selectedDate as Date
//                }
//                if rightMostDate == nil {
//                    rightMostDate = selectedDate as Date
//                } else if selectedDate as Date > rightMostDate! {
//                    rightMostDate = selectedDate as Date
//                }
//            }
//            
//            formatter.dateFormat = "MM/dd/yyyy"
//            let leftMostDateAsString = formatter.string (from: leftMostDate!)
//            let rightMostDateAsString = formatter.string (from: rightMostDate!)
//            if leftDateTimeArrays[leftMostDateAsString] == nil {
//                mostRecentSelectedCellDate = leftMostDate! as NSDate
//                leftDateTimeArrays.removeAllObjects()
//                
//                let availableTimeOfDayInCell = ["Anytime"]
//                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
//                
//                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
//                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//                }
//                if cell?.selectedPosition() == .right {
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//                }
//                
//                //                //Update trip preferences in dictionary
//                //                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//                //                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//                //                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//                //
//                //                //Save
//                //                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
//                //
//            }
//            //
//            if rightDateTimeArrays[rightMostDateAsString] == nil {
//                mostRecentSelectedCellDate = rightMostDate! as NSDate
//                rightDateTimeArrays.removeAllObjects()
//                
//                let availableTimeOfDayInCell = ["Anytime"]
//                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
//                
//                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
//                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//                }
//                if cell?.selectedPosition() == .right {
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//                }
//                
//                //                //Update trip preferences in dictionary
//                //                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//                //                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//                //                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//                //
//                //                //Save
//                //                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
//            }
//            
//        }
//        
//        // Create dictionary of selected dates and destinations
//        var datesDestinationsDictionary = [String:[Date]]()
//        datesDestinationsDictionary["destinationTBD"] = selectedDates as [Date]
//        getLengthOfSelectedAvailabilities()
//        //Update trip preferences in dictionary
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
//        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
//        //Save
//        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//        
        
    }
    
//    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
//        
//        if cellState.dateBelongsTo != .thisMonth || cellState.date < Date() {
//            return false
//        }
//        return true
//    }
    
    // MARK custom func to get length of selected availability segments
    func getLengthOfSelectedAvailabilities() {
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        if selectedDates.count > 0 {
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .left {
                    leftDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .right {
                    rightDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .full {
                    fullDates.append(date as Date)
                }
            }
            if rightDates != [] && leftDates != [] {
                for segment in 0...leftDates.count - 1 {
                    let segmentAvailability = rightDates[segment].timeIntervalSince(leftDates[segment]) / 86400 + 1
                    lengthOfAvailabilitySegmentsArray.append(Int(segmentAvailability))
                }
            } else {
                lengthOfAvailabilitySegmentsArray = [1]
            }
        } else {
            lengthOfAvailabilitySegmentsArray = [0]
        }
    }
    
    // MARK: Calendar header functions
    // Sets the height of your header
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 21)
    }
    
    // This setups the display of your header
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        
        let headerCell = calendarView?.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "monthHeaderView", for: indexPath) as! monthHeaderView
        
        formatter.dateFormat = "MMMM yyyy"
        let stringForHeader = formatter.string(from: range.start)
        headerCell.monthLabel.text = stringForHeader
        
        return headerCell
    }
    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton)
            }
        }
    }
}
