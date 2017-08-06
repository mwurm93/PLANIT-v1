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

class ParseDatesForMultipleDestinationsCalendarView: UIView, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    //Class UI object vars
    var questionLabel: UILabel?
    var formatter = DateFormatter()
    var leftDate: Date?
    var button1: UIButton?
    var button2: UIButton?
    var destinationDaysTableView: UITableView?
    var timesLoaded = 0

    
    //Cache color vars
    static let transparentColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
    static let whiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
    static let transparentWhiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
    static let darkGrayColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
    static let blackColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
    var selectionColor = UIColor()
    var selectionColorTransparent = UIColor()
    var colors = ["Silver","Turquoise", "Pomegranate","Carrot", "Pumpkin", "Alizarin", "Peter River", "Turquoise", "Green Sea", "Asbestos"]

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
        
        questionLabel?.frame = CGRect(x: 10, y: 15, width: bounds.size.width - 20, height: 50)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 540
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.sizeToFit()
        button2?.frame.size.height = 30
        button2?.frame.size.width += 20
        button2?.frame.origin.x = (bounds.size.width - (button2?.frame.width)!) / 2
        button2?.frame.origin.y = 490
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        button2?.isHidden = true
        
        calendarView?.frame = CGRect(x: 13, y: 250, width: 350, height: 200)
        calendarView?.cellSize = 50
        
        destinationDaysTableView?.frame = CGRect(x: (bounds.size.width - 300) / 2, y: 48, width: 300, height: 200)
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
        loadDates()
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.lightGray, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.lightGray.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Change trip dates", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.setTitleColor(UIColor.white, for: .normal)
        button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.numberOfLines = 0
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("Done", for: .normal)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)

        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "How many nights in each\ndestination (\((tripDates?.count)! - 1) total)?"
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
        
        selectionColor = colorForName(colors[0])
        selectionColorTransparent = selectionColor.withAlphaComponent(0.35)
    }
    
    
    
    //UITextfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        
        var differenceInNightsCount = 0
        for i in 0 ... destinationsForTrip.count - 1 {
            if textField.tag == i {
                //Update textfields to match total
                let previousNightsCount = (datesDestinationsDictionary[destinationsForTrip[i]]?.count)! - 1
                differenceInNightsCount = previousNightsCount - Int(textField.text!)!
                
                var row = Int()
                if i == destinationsForTrip.count - 1 {
                    row = destinationsForTrip.count - 2
                } else {
                    row = i + 1
                }
                let cellForUpdate = destinationDaysTableView?.cellForRow(at: IndexPath(row: row, section: 0)) as! destinationDaysTableViewCell
                if cellForUpdate.cellTextField.text! != "?" && cellForUpdate.cellTextField.text! != ""{
                    let previousNightsCountForUpdate = Int(cellForUpdate.cellTextField.text!)!
                    cellForUpdate.cellTextField.text = String(previousNightsCountForUpdate + differenceInNightsCount)
                } else {
                    cellForUpdate.cellTextField.text = String(differenceInNightsCount)
                }
                
                //Update datasource
                travelDates.removeAll()
                var sinceDate = tripDates?[0]
                for i in 0 ... destinationsForTrip.count - 2 {
                    let cell = destinationDaysTableView?.cellForRow(at: IndexPath(row: i, section: 0)) as! destinationDaysTableViewCell
                    let selectedDays = Int(cell.cellTextField.text!)!
                    let travelDateToAppend = Date(timeInterval: TimeInterval(86400 * selectedDays), since: sinceDate!)
                    sinceDate = travelDateToAppend
                    travelDates.append(travelDateToAppend)
                }
                parseTripDatesByTravelDates()
                
                timesLoaded += 1
                //Update calendar
                calendarView.reloadDates(calendarView.selectedDates)
            }
        }
        
        //Hide done button if any ? marks still
        var anyQuestionMarks = String()
        for i in 0 ... destinationsForTrip.count - 1 {
            let cell = destinationDaysTableView?.cellForRow(at: IndexPath(row: i, section: 0)) as! destinationDaysTableViewCell
            anyQuestionMarks.append(cell.cellTextField.text!)
        }
        if anyQuestionMarks.contains("?") {
            button2?.isHidden = true
        } else {
            button2?.isHidden = false
        }
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        //Hide done button if any ? marks still
        var anyQuestionMarks = String()
        for i in 0 ... destinationsForTrip.count - 1 {
            let cell = destinationDaysTableView?.cellForRow(at: IndexPath(row: i, section: 0)) as! destinationDaysTableViewCell
            anyQuestionMarks.append(cell.cellTextField.text!)
        }
        if anyQuestionMarks.contains("?") {
            button2?.isHidden = true
        } else {
            button2?.isHidden = false
        }

        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "?" {
            textField.text = ""
            return true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.characters.count == 0) {
            return true
        }
        
        if (textField.text == "") && string == "0" {
            return false
        } else if string == "\n" {
            return true
        } else if Int(textField.text! + string)! >= (tripDates?.count)! - 1 {
            return false
        }
        
        let acceptableCharacters = "0123456789"
        let cs = NSCharacterSet(charactersIn: acceptableCharacters)
        let filtered = string.components(separatedBy: cs as CharacterSet).filter {  !$0.isEmpty }
        let str = filtered.joined(separator: "")
        
        return (string != str)
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
        destinationDaysTableView?.register(destinationDaysTableViewCell.self, forCellReuseIdentifier: "destinationDaysTableViewCell")
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
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        
        cell.destinationLabel.text = destinationsForTrip[indexPath.row]
        
        
        cell.cellTextField.delegate = self
        cell.cellTextField.tag = indexPath.row
        if timesLoaded != 0 {
            //Number of days
            cell.cellTextField.text = String((datesDestinationsDictionary[destinationsForTrip[indexPath.row]]!).count -
            1)
        } else {
            cell.cellTextField.text = "?"
            button2?.isHidden = true
        }
        
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = nil
        cell.layer.backgroundColor = colorForName(colors[indexPath.row]).withAlphaComponent(0.35).cgColor
        
        
//        let test = type(of: view).description().range(of: "Reorder") != nil
        
        
//        //Change hamburger icon
//        for view in cell.subviews as [UIView] {
//            if type(of: view).description().range(of: "Reorder") != nil {
//                for subview in view.subviews as! [UIImageView] {
//                    if subview.isKind(of: UIImageView.self) {
//                        subview.image = UIImage(named: "hamburger")
//                        subview.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
//                    }
//                }
//            }
//        }
        if indexPath.row == destinationsForTrip.count - 1 {
            timesLoaded += 1
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        var destinationsForTripStates = SavedPreferencesForTrip["destinationsForTripStates"] as! [String]
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        
        let movedDestinationForTrip = destinationsForTrip[sourceIndexPath.row]
        destinationsForTrip.remove(at: sourceIndexPath.row)
        destinationsForTrip.insert(movedDestinationForTrip, at: destinationIndexPath.row)
        
        let movedDestinationForTripStates = destinationsForTripStates[sourceIndexPath.row]
        destinationsForTripStates.remove(at: sourceIndexPath.row)
        destinationsForTripStates.insert(movedDestinationForTripStates, at: destinationIndexPath.row)
        
        if travelDictionaryArray.count == destinationsForTrip.count {
            let movedtravelDictionaryArray = travelDictionaryArray[sourceIndexPath.row]
            travelDictionaryArray.remove(at: sourceIndexPath.row)
            travelDictionaryArray.insert(movedtravelDictionaryArray, at: destinationIndexPath.row)
        }
        
        if placeToStayDictionaryArray.count == destinationsForTrip.count {
            let movedPlaceToStayDictionaryArray = placeToStayDictionaryArray[sourceIndexPath.row]
            placeToStayDictionaryArray.remove(at: sourceIndexPath.row)
            placeToStayDictionaryArray.insert(movedPlaceToStayDictionaryArray, at: destinationIndexPath.row)
        }
        
        travelDates.removeAll()
        var sinceDate = tripDates?[0]
        for i in 0 ... destinationsForTrip.count - 2 {
            let selectedDays = (datesDestinationsDictionary[destinationsForTrip[i]]!).count - 1
            let travelDateToAppend = Date(timeInterval: TimeInterval(86400 * selectedDays), since: sinceDate!)
            sinceDate = travelDateToAppend
            travelDates.append(travelDateToAppend)
        }
        
        let movedColor = colors[sourceIndexPath.row]
        colors.remove(at: sourceIndexPath.row)
        colors.insert(movedColor, at: destinationIndexPath.row)
    
        let datesDestinationsDictionaryTest = datesDestinationsDictionary as! [String:[Date]]
        let destinationsForTripTest = destinationsForTrip as! [String]
        
        //Save
        SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
        SavedPreferencesForTrip["destinationsForTripStates"] = destinationsForTripStates
        SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
        SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        timesLoaded -= 1
        if timesLoaded > 0 {
            calendarView.reloadDates(calendarView.selectedDates)
        }
        tableView.reloadData()
        
        parseTripDatesByTravelDates()

    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
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
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if (tripDates?.contains(date))! {
            return true
        }
        return false
    }
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
        if date == (tripDates?[0])! || date == (tripDates?[(tripDates?.count)! - 1 ])! {
            return false
        }
        return true
    }
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        let myCustomCell = cell as? CellView
        
        switch cellState.selectedPosition() {
        case .full:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = colorForName(colors[0]).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = colorForName(colors[0]).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.layer.backgroundColor = colorForName(colors[0]).withAlphaComponent(0.35).cgColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = colorForName(colors[0]).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.layer.backgroundColor = colorForName(colors[0]).withAlphaComponent(0.35).cgColor
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = colorForName(colors[0]).withAlphaComponent(0.35).cgColor
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
                selectionColor = colorForName(colors[i + 1])
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
                        myCustomCell?.leftSideConnector.layer.backgroundColor = selectionColorTransparent.cgColor
                    }
                }
            }
        }
        if cellState.selectedPosition() == .left {
            myCustomCell?.rightSideConnector.layer.backgroundColor = colorForName(colors[0]).withAlphaComponent(0.35).cgColor
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
                    fromDestination += 1
                    toDestination += 1
                }
            } else {
                travelDates.removeAll()
                travelDates.append(date)
                fromDestination = 0
                toDestination = 1
                fromDestination += 1
                toDestination += 1
            }
        }
        calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        calendarView?.reloadDates(calendarView.selectedDates)
        
        if (destinationsForTrip.count - 1) >= toDestination {
        
            UIView.animate(withDuration: 1) {
            }
            fromDestination += 1
            toDestination += 1
        } else {
            destinationDaysTableView?.reloadData()
            parseTripDatesByTravelDates()
        }
        
        //Hide done button if any ? marks still
        var anyQuestionMarks = String()
        for i in 0 ... destinationsForTrip.count - 1 {
            let cell = destinationDaysTableView?.cellForRow(at: IndexPath(row: i, section: 0)) as! destinationDaysTableViewCell
            anyQuestionMarks.append(cell.cellTextField.text!)
        }
        if anyQuestionMarks.contains("?") {
            button2?.isHidden = true
        } else {
            button2?.isHidden = false
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
    
    
    
    
    //Customer functions
    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if sender == button2 {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
                var anyQuestionMarks = String()
                for i in 0 ... destinationsForTrip.count - 1 {
                    let cell = destinationDaysTableView?.cellForRow(at: IndexPath(row: i, section: 0)) as! destinationDaysTableViewCell
                    anyQuestionMarks.append(cell.cellTextField.text!)
                }
                
                if !anyQuestionMarks.contains("?") {
                    let when = DispatchTime.now() + 0.3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        if SavedPreferencesForTrip["assistantMode"] as! String == "dates" {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsComplete_backToItinerary"), object: nil)
                        } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsComplete"), object: nil)
                        }
                    }
                }

            }
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle! as NSString, color: UIColor.white)
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
