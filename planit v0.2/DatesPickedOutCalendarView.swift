//
//  DatesPickedOutCalendarView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/18/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DatesPickedOutCalendarView: UIView, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    //Class UI object vars
    var questionLabel: UILabel?
    var formatter = DateFormatter()
    var button1: UIButton?
    
    //Cache color vars
    static let transparentColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
    static let whiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
    static let transparentWhiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
    static let darkGrayColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
    static let blackColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
    
    //Clas data object vars
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()

    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 15, width: bounds.size.width - 20, height: 50)
        calendarView?.frame = CGRect(x: 13, y: 100, width: 350, height: 400)
        calendarView?.cellSize = 50
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 520
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        button1?.isHidden = true
        
        loadDates()
    }
    
    func loadDates() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        // Load trip preferences and install
        if let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date] {
            if selectedDatesValue.count > 0 {
                self.calendarView.selectDates(selectedDatesValue as [Date],triggerSelectionDelegate: false)
            }
        }
    }
//    func scrollToDate() {
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date]
//        let scrollToDate = selectedDatesValue?[0]
//        calendarView.scrollToDate(scrollToDate!, animateScroll: true)
//    }

    func addViews() {
        
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
        button1?.setTitle("Back to travel dates", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Select dates for your trip!"
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
        
        if leftDateTimeArrays.count >= 1 && rightDateTimeArrays.count >= 1 {
            calendarView?.deselectAllDates(triggerSelectionDelegate: false)
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
        
        //UNCOMMENT FOR TWO CLICK RANGE SELECTION
        let leftKeys = leftDateTimeArrays.allKeys
        let rightKeys = rightDateTimeArrays.allKeys
        if leftKeys.count == 1 && rightKeys.count == 0 {
            formatter.dateFormat = "MM/dd/yyyy"
            let leftDate = formatter.date(from: leftKeys[0] as! String)
            if date > leftDate! {
                calendarView?.selectDates(from: leftDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                let when = DispatchTime.now() + 0.15
                DispatchQueue.main.asyncAfter(deadline: when) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tripCalendarRangeSelected"), object: nil)
                }
                
            } else {
                calendarView?.deselectAllDates(triggerSelectionDelegate: false)
                rightDateTimeArrays.removeAllObjects()
                leftDateTimeArrays.removeAllObjects()
                calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }
        
        handleSelection(cell: cell, cellState: cellState)
        
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        // Create dictionary of selected dates and destinations
        var datesDestinationsDictionary = [String:[Date]]()
        datesDestinationsDictionary["destinationTBD"] = selectedDates as [Date]
        getLengthOfSelectedAvailabilities()
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates as [Date]
        SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)        
        
        mostRecentSelectedCellDate = date as NSDate
        
        let availableTimeOfDayInCell = ["Anytime"]
        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString

        formatter.dateFormat = "MM/dd/yyyy"

        let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        if cell?.selectedPosition() == .right {
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        
//        //Update trip preferences in dictionary
//        let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//        SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//        
//        //Save
//        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleSelection(cell: cell, cellState: cellState)
        getLengthOfSelectedAvailabilities()
        
        if lengthOfAvailabilitySegmentsArray.count > 1 || (leftDates.count > 0 && rightDates.count > 0 && fullDates.count > 0) || fullDates.count > 1 {
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            lengthOfAvailabilitySegmentsArray.removeAll()
            calendarView?.deselectAllDates(triggerSelectionDelegate: false)
            return
        }
        
        // Create array of selected dates
        calendarView?.deselectDates(from: date, to: date, triggerSelectionDelegate: false)
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        
        if selectedDates.count > 0 {
            
            var leftMostDate: Date?
            var rightMostDate: Date?
            
            for selectedDate in selectedDates {
                if leftMostDate == nil {
                    leftMostDate = selectedDate as Date
                } else if leftMostDate! > selectedDate as Date {
                    leftMostDate = selectedDate as Date
                }
                if rightMostDate == nil {
                    rightMostDate = selectedDate as Date
                } else if selectedDate as Date > rightMostDate! {
                    rightMostDate = selectedDate as Date
                }
            }
            
            formatter.dateFormat = "MM/dd/yyyy"
            let leftMostDateAsString = formatter.string (from: leftMostDate!)
            let rightMostDateAsString = formatter.string (from: rightMostDate!)
            if leftDateTimeArrays[leftMostDateAsString] == nil {
                mostRecentSelectedCellDate = leftMostDate! as NSDate
                leftDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                if cell?.selectedPosition() == .right {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                
//                //Update trip preferences in dictionary
//                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//                
//                //Save
//                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
//                
            }
            //
            if rightDateTimeArrays[rightMostDateAsString] == nil {
                mostRecentSelectedCellDate = rightMostDate! as NSDate
                rightDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                if cell?.selectedPosition() == .right {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                
//                //Update trip preferences in dictionary
//                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
//                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
//                
//                //Save
//                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
            }
            
        }
        
        // Create dictionary of selected dates and destinations
        var datesDestinationsDictionary = [String:[Date]]()
        datesDestinationsDictionary["destinationTBD"] = selectedDates as [Date]
        getLengthOfSelectedAvailabilities()
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates as [Date]
        SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        if cellState.dateBelongsTo != .thisMonth || cellState.date < Date() {
            return false
        }
        return true
    }
    
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
