//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

enum JRFilterMode : Int {
    case jrFilterComplexMode = 0
    case jrFilterSimpleSearchMode = 1
    case jrFilterTravelSegmentMode = 2
}


class JRFilterVC: JRViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var toolbarLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarSeparatorViewHeightConstraint: NSLayoutConstraint!
    weak var resetBarButtonItem: UIBarButtonItem?
    var sections = [Any]()
    var cellsFactory: JRFilterCellsFactory?
    var itemsFactory: JRFilterItemsFactory?
    private(set) var selectedTravelSegment: JRSDKTravelSegment?
    private(set) var filter: JRFilter?
    private(set) var filterMode = JRFilterMode(rawValue: 0)!

    init(filter: JRFilter, for filterMode: JRFilterMode, selectedTravelSegment travelSegment: JRSDKTravelSegment) {
        super.init(nibName: "JRFilterVC", bundle: AVIASALES_BUNDLE)
        
        self.filter = filter
        self.filterMode = filterMode
        selectedTravelSegment = travelSegment
        itemsFactory = JRFilterItemsFactory(filter: filter)
        updateTableDataSource()
    
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

//merk - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JRColorScheme.mainBackgroundColor()
        cellsFactory = JRFilterCellsFactory(tableView: tableView, with: filterMode)
        setupResetBarButton()
        setupNavigationBar()
        reloadViews()
        registerNotifications()
        toolbarSeparatorViewHeightConstraint.constant = JRPixel()
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, kJRFilterTableViewBottomInset, 0.0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.deselectRow(at: tableView.indexPathForSelectedRow, animated: true)
        tableView.flashScrollIndicators()
    }

// MARK: - Protected methds
    func setupResetBarButton() {
        let resetBarButtonItem = UIBarButtonItem(title: NSLS("JR_FILTER_RESET"), style: .plain, target: self, action: #selector(self.resetBarButtonAction))
        navigationItem.rightBarButtonItem = resetBarButtonItem
        self.resetBarButtonItem = resetBarButtonItem
    }

    @IBAction func resetBarButtonAction(_ sender: UIBarButtonItem) {
        switch filterMode {
            case .jrFilterTravelSegmentMode:
                filter?.resetFilterBounds(for: selectedTravelSegment)
            default:
                filter?.resetAllBounds()
        }

    }

    func showFilters(for travelSegment: JRSDKTravelSegment) {
        let segmentFilterVC = JRFilterVC(filter: filter, for: .jrFilterTravelSegmentMode, selectedTravelSegment: travelSegment)
        navigationController?.pushViewController(segmentFilterVC as? UIViewController ?? UIViewController(), animated: true)
    }

    func updateToolbar() {
        var toolbarLabelText: NSMutableAttributedString?
        if filter.filteredTickets?.count == 0 {
            toolbarLabelText = NSMutableAttributedString(string: NSLS("JR_FILTER_TICKETS_NOT_FOUND"))
        }
        else {
            let ticketsCount: Int? = filter.filteredTickets?.count
            let numbersFont = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
            let minPriceString: String = JRPriceUtils.formattedPrice(inUserCurrency: filter.minFilteredPrice)
            let foundTicketsCountString = String((filter.filteredTickets?.count))
            let format: String = NSLSP("JR_FILTER_FLIGHTS_FOUND_MIN_PRICE", ticketsCount)
            let text = String(format: format, ticketsCount, minPriceString)
            toolbarLabelText = NSMutableAttributedString(string: text, attributes: nil)
            toolbarLabelText?.addAttribute(NSFontAttributeName, value: numbersFont, range: (toolbarLabelText?.string? as NSString).range(of: foundTicketsCountString))
            toolbarLabelText?.addAttribute(NSFontAttributeName, value: numbersFont, range: (toolbarLabelText?.string? as NSString).range(of: minPriceString))
        }
        let oldString: String = toolbarLabel.attributedText.string
        if !(toolbarLabelText?.string == oldString) {
            toolbarLabel.attributedText = toolbarLabelText
        }
    }

    func setupNavigationBar() {
        if filterMode == .jrFilterTravelSegmentMode {
            title = "\(selectedTravelSegment?.originAirport?.iata) – \(selectedTravelSegment?.destinationAirport?.iata)"
        }
        else {
            let closeItem: UIBarButtonItem? = UINavigationItem.barItem(withImageName: "filtersCrossButton", target: self, action: #selector(self.closeButtonAction))
            navigationItem.leftBarButtonItems = [closeItem]
            title = NSLS("JR_FILTER_BUTTON")
        }
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem
    }

// MARK: - Notifications
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.filterBoundsDidReset), name: kJRFilterBoundsDidResetNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.filterBoundsDidChange), name: kJRFilterBoundsDidChangeNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.filterMinPriceDidUpdate), name: kJRFilterMinPriceDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyDidChange), name: kAviasalesCurrencyDidUpdateNotificationName, object: nil)
    }

    func filterBoundsDidReset(_ notification: Notification) {
        reloadViews()
    }

    func filterBoundsDidChange(_ notification: Notification) {
        updateResetButton()
    }

    func filterMinPriceDidUpdate(_ notification: Notification) {
        updateToolbar()
    }

    func currencyDidChange(_ notification: Notification) {
        reloadViews()
    }

// MARK: - Private methods
    func updateTableDataSource() {
        switch filterMode {
            case .jrFilterComplexMode:
                sections = itemsFactory?.createSectionsForComplexMode()
            case .jrFilterSimpleSearchMode:
                sections = itemsFactory?.createSectionsForSimpleMode()
            case .jrFilterTravelSegmentMode:
                sections = itemsFactory?.createSections(for: selectedTravelSegment)
            default:
                break
        }

    }

    func reloadViews() {
        updateTableDataSource()
        updateResetButton()
        updateToolbar()
        tableView.reloadData()
    }

    func updateResetButton() {
        switch filterMode {
            case .jrFilterTravelSegmentMode:
                resetBarButtonItem.isEnabled = !filter?.isTravelSegmentBoundsReseted(for: selectedTravelSegment)
            default:
                resetBarButtonItem.isEnabled = !filter?.isAllBoundsReseted()
        }

    }

// MARK: - Actions
    func closeButtonAction(_ sender: Any) {
        if filter.filteredTickets?.count == 0 {
            showAlert(withTitle: NSLS("JR_FILTER_EMPTY_ALERT_TITLE"), message: NSLS("JR_FILTER_EMPTY_ALERT_DESCRIPTION"), cancelButtonTitle: NSLS("JR_OK_BUTTON"))
        }
        else {
            dismiss(animated: true) { _ in }
        }
    }

// MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items: [JRFilterItemProtocol]? = sections[section]
        var numberOfRows: Int? = items?.count
        let headerItem: JRFilterListHeaderItem? = (items?.first as? JRFilterListHeaderItem)
        if headerItem && (headerItem? is JRFilterListHeaderItem) {
            numberOfRows = headerItem?.isExpanded ? items?.count : 1
        }
        return numberOfRows!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items: [JRFilterItem]? = sections[indexPath.section]
        let item: JRFilterItem? = items[indexPath.row]
        let cell: UITableViewCell? = cellsFactory?.cell(by: item)
        return cell!
    }

// MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items: [JRFilterItemProtocol]? = sections[indexPath.section]
        let item: JRFilterItemProtocol = items[indexPath.row]
        if (item is JRFilterTravelSegmentItem) && filterMode == .jrFilterComplexMode {
            let travelSegmentItem: JRFilterTravelSegmentItem? = (item as? JRFilterTravelSegmentItem)
            showFilters(for: travelSegmentItem?.travelSegment)
        }
        else if (item is JRFilterCheckBoxItem) {
            let cell: JRFilterCheckboxCell? = (tableView.cellForRow(at: indexPath) as? JRFilterCheckboxCell)
            cell?.checked = !cell?.checked
        }
        else if (item is JRFilterListHeaderItem) {
            let cell: JRFilterListHeaderCell? = (tableView.cellForRow(at: indexPath) as? JRFilterListHeaderCell)
            cell?.setExpanded(!cell?.isExpanded, animated: true)
            tableView.reloadSections(IndexSet(index: indexPath.section), with: .automatic)
            tableView.selectRow(at: indexPath as? IndexPath ?? IndexPath(), animated: true, scrollPosition: .middle)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else {
            tableView.deselectRow(at: indexPath, animated: true)
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items: [JRFilterItem]? = sections[indexPath.section]
        let item: JRFilterItem? = items[indexPath.row]
        return cellsFactory?.heightForCell(by: item)!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kJRFilterHeigthForHeader
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return JRPixel()
    }
}

let kJRFilterHeigthForHeader = 20.0
let kJRFilterCellBottomLineOffset = 34.0
let kkJRFilterResetButtonHiAlpha = 0.75
let kkJRFilterResetButtonDisabled = 0.4
let kJRFilterTableViewBottomInset = 50.0