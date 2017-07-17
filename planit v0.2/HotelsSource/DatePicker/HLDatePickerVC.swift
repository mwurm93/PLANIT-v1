//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
private var kDayCellIdentifier: String = "JRDatePickerDayCell"
private var kMonthReusableHeaderViewIdentifier: String = "JRDatePickerMonthHeaderReusableView"

protocol HLDatePickerVCDelegate: NSObjectProtocol {
    func datesSelected(_ datePickerVC: HLDatePickerVC)
}

class HLDatePickerVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, HLDatePickerStateObjectActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: HLDatePickerVCDelegate?
    private(set) var dayOfWeekView: DayOfWeekView?
    @IBOutlet weak var dayOfWeekBackgroundView: UIView!
    var searchInfo: HLSearchInfo?
    var stateObject: HLDatePickerStateObject?

    var isNeedsToScrollToSelectedDates: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        fixTableViewInsets()
        searchInfo?.updateExpiredDates()
        registerNibs()
        title = NSLS("HL_LOC_DATE_PICKER_TITLE")
        stateObject = HLDatePickerStateObject(delegate: self)
        stateObject?.firstSelectedDate = searchInfo?.checkInDate
        stateObject?.secondSelectedDate = searchInfo?.checkOutDate
        buildTable()
        isNeedsToScrollToSelectedDates = true
        disableScroll(forInteractivePopGesture: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if isNeedsToScrollToSelectedDates {
            tableView.scrollToRow(at: stateObject?.indexPathToScroll, at: .top, animated: false)
            isNeedsToScrollToSelectedDates = false
        }
    }

// MARK: - Private methods
    func fixTableViewInsets() {
            // Change insets for fixing double separator (from top section and bottom of nav bar)
            // After this top section separator will be under bottom nav bar separator
        let insets: UIEdgeInsets = tableView.contentInset
        tableView.contentInset = UIEdgeInsetsMake(insets.top() - 1, insets.left, insets.bottom(), insets.right)
    }

    func registerNibs() {
        tableView.register(JRDatePickerDayCell.self, forCellReuseIdentifier: kDayCellIdentifier)
        let headerNib = UINib(nibName: kMonthReusableHeaderViewIdentifier, bundle: nil)
        tableView.register(headerNib as? UINib ?? UINib(), forHeaderFooterViewReuseIdentifier: kMonthReusableHeaderViewIdentifier)
    }

    func buildTable() {
        var datesToRepresent = [Any]()
        if !stateObject?.borderDate {
            stateObject?.borderDate = DateUtil.borderDate()
        }
        let firstMonth: Date? = DateUtil.firstDayOfMonth(DateUtil.resetTime(forDate: DateUtil.today()))
        datesToRepresent.append(firstMonth)
        for i in 1...12 {
            let prevMonth: Date? = datesToRepresent[i - 1]
            datesToRepresent.append(DateUtil.firstDayOfNextMonth(for: prevMonth))
        }
        for date: Date in datesToRepresent {
            stateObject?.monthItems?.append(HLDatePickerMonthItem(firstDateOfMonth: date, stateObject: stateObject))
        }
        stateObject?.updateSelectedDatesRange()
    }

// MARK: - JRDatePickerStateObjectActionDelegate Methods
    func dateWasSelected(_ date: Date) {
        stateObject?.select(date)
        stateObject?.updateSelectedDatesRange()
        tableView.reloadData()
        if stateObject?.areDatesSelectedProperly() {
            tableView.isUserInteractionEnabled = false
            let savedState: HLDatePickerStateObject? = stateObject?
            weakify(self)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((int64_t)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                strongify(self)
                self.goBack(with: savedState)
            })
        }
        else {
            stateObject?.restrictCheckoutDate()
        }
    }

    func showRestrictionToast() {
        let toast: HLToastView? = HLAlertsFabric.datesRestrictionToast()
        showToast(toast, animated: true)
    }

// MARK: - UITableViewDelegate Methods
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

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 13.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

    func goBack(with state: HLDatePickerStateObject) {
        if state.areDatesSelectedProperly() {
            searchInfo?.checkInDate = state.firstSelectedDate
            searchInfo?.checkOutDate = state.secondSelectedDate
        }
        delegate?.datesSelected(self)
        super.goBack()
    }

// MARK: - IBActions
    func goBack() {
        goBack(with: stateObject)
    }
}