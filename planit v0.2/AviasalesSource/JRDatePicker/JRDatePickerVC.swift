//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

typealias JRDatePickerVCSelecionBlock = (_ selectedDate: Date) -> Void
private let kDatePickerCollectionHeaderHeight: Int = 65
private let kDayCellIdentifier: String = "JRDatePickerDayCell"
private let kMonthReusableHeaderViewIdentifier: String = "JRDatePickerMonthHeaderReusableView"

class JRDatePickerVC: JRViewController, UITableViewDataSource, UITableViewDelegate, JRDatePickerStateObjectActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    var stateObject: JRDatePickerStateObject?
    var selectionBlock = JRDatePickerVCSelecionBlock()

    init(mode: JRDatePickerMode, borderDate: Date, firstDate: Date, secondDate: Date, selectionBlock: JRDatePickerVCSelecionBlock) {
        super.init()
        
        stateObject = JRDatePickerStateObject(delegate: self)
        stateObject?.firstSelectedDate = firstDate
        stateObject?.borderDate = borderDate
        stateObject?.secondSelectedDate = secondDate
        stateObject?.mode = mode
        self.selectionBlock = selectionBlock
        buildTable()
    
    }

    func registerNibs() {
        tableView.register(JRDatePickerDayCell.self, forCellReuseIdentifier: kDayCellIdentifier)
        let headerNib = UINib(nibName: kMonthReusableHeaderViewIdentifier, bundle: nil)
        tableView.register(headerNib as? UINib ?? UINib(), forHeaderFooterViewReuseIdentifier: kMonthReusableHeaderViewIdentifier)
    }

    func setupTitle() {
        if stateObject?.mode == JRDatePickerModeReturn {
            title = NSLS("JR_DATE_PICKER_RETURN_DATE_TITLE")
        }
        else {
            title = NSLS("JR_DATE_PICKER_DEPARTURE_DATE_TITLE")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        setupTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        tableView.scrollToRow(at: stateObject?.indexPathToScroll, at: .top, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    func buildTable() {
        var datesToRepresent = [Any]()
        if !stateObject?.borderDate {
            stateObject?.borderDate = DateUtil.firstAvalibleForSearchDate()
        }
        let firstMonth: Date? = DateUtil.firstDayOfMonth(DateUtil.resetTime(forDate: DateUtil.today()))
        datesToRepresent.append(firstMonth)
        for i in 1...12 {
            let prevMonth: Date? = datesToRepresent[i - 1]
            datesToRepresent.append(DateUtil.nextMonth(for: prevMonth))
        }
        for date: Date in datesToRepresent {
            stateObject?.monthItems?.append(JRDatePickerMonthItem(firstDateOfMonth: date, stateObject: stateObject))
        }
        stateObject?.updateSelectedDatesRange()
    }

    func dateWasSelected(_ date: Date) {
        switch stateObject?.mode {
            case JRDatePickerModeDefault, JRDatePickerModeDeparture:
                stateObject?.firstSelectedDate = date
            case JRDatePickerModeReturn:
                stateObject?.secondSelectedDate = date
        }

        stateObject?.updateSelectedDatesRange()
        tableView.reloadData()
        if selectionBlock {
            selectionBlock(date)
        }
        popOrDismissBasedOnDeviceTypeWith(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return stateObject?.monthItems?.count!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let monthItem: JRDatePickerMonthItem? = (stateObject?.monthItems)[section]
        return monthItem?.weeks?.count!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JRDatePickerDayCell? = tableView.dequeueReusableCell(withIdentifier: kDayCellIdentifier)
        let monthItem: JRDatePickerMonthItem? = (stateObject?.monthItems)[indexPath.section]
        let dates: [Any]? = (monthItem?.weeks)[indexPath.row]
        cell?.setDatePickerItem(monthItem, dates: dates)
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: JRDatePickerMonthHeaderReusableView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: kMonthReusableHeaderViewIdentifier)
        sectionHeaderView?.monthItem = (stateObject?.monthItems)[section]
        return sectionHeaderView!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.width / 7
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kDatePickerCollectionHeaderHeight
    }
}