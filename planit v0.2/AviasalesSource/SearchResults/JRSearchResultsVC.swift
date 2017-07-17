//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSearchResultsVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

private let kJRAviasalesAdIndex: Int = 0
private let kHotelCardIndex: Int = 5

class JRSearchResultsVC: JRViewController, JRSearchResultsListDelegate, JRFilterDelegate {
    @IBOutlet weak var tableView: UITableView!
    var selectionBlock: ((_ selectedTicket: JRSDKTicket) -> Void)? = nil
    var filterChangedBlock: ((_ isEmptyResults: Bool) -> Void)? = nil

    private var _resultsList: JRSearchResultsList?
    var resultsList: JRSearchResultsList? {
        if !_resultsList {
                _resultsList = JRSearchResultsList(cellNibName: JRResultsTicketCell.nibFileName())
                _resultsList.flightSegmentLayoutParameters = JRSearchResultsFlightSegmentCellLayoutParameters(tickets: tickets(), font: UIFont.systemFont(ofSize: 12))
                _resultsList.delegate = self
            }
            return _resultsList
    }
    private var _ads: JRAdvertisementTableManager?
    var ads: JRAdvertisementTableManager? {
        if !_ads {
                _ads = JRAdvertisementTableManager()
                _ads.aviasalesAd = JRAdvertisementManager.sharedInstance.cachedAviasalesAdView
                _ads.hotelCard = createHotelCardIfNeeded()
                if _ads.aviasalesAd {
                    adsIndexSet.add(kJRAviasalesAdIndex)
                }
                if _ads.hotelCard {
                    adsIndexSet.add(kHotelCardIndex)
                }
            }
            return _ads
    }
    private var _tableManager: JRTableManagerUnion?
    var tableManager: JRTableManagerUnion? {
        if !_tableManager {
                _tableManager = JRTableManagerUnion(firstManager: resultsList, secondManager: ads, secondManagerPositions: adsIndexSet)
            }
            return _tableManager
    }
    var searchInfo: JRSDKSearchInfo?
    var response: JRSDKSearchResult?
    private var _filter: JRFilter?
    var filter: JRFilter? {
        if !_filter {
                _filter = JRFilter(tickets: response?.tickets, searchInfo: searchInfo)
                _filter.delegate = self
            }
            return _filter
    }
    private var _adsIndexSet: IndexSet?
    var adsIndexSet: IndexSet? {
        if !_adsIndexSet {
                _adsIndexSet = IndexSet()
            }
            return _adsIndexSet
    }
    var isShouldShowMetropolitanResultsInfoAlert: Bool = false
    var isTableViewInsetsDidSet: Bool = false
    var flightSegmentLayoutParameters: JRSearchResultsFlightSegmentCellLayoutParameters?

    init(searchInfo: JRSDKSearchInfo, response: JRSDKSearchResult) {
        super.init()
        
        self.searchInfo = searchInfo
        self.response = response
        isShouldShowMetropolitanResultsInfoAlert = !response.searchResultInfo.isStrict
    
    }

// MARK: - Properties

    func createHotelCardIfNeeded() -> JRHotelCardView {
        var hotelCardView: JRHotelCardView? = nil
        if InteractionManager.shared.isCityReadyForSearchHotels && hotelsEnabled() && JRSDKModelUtils.isSimpleSearch(searchInfo) {
            hotelCardView = JRHotelCardView.loadFromNib()
            weak var weakSelf: JRSearchResultsVC? = self
            hotelCardView?.buttonAction = {() -> Void in
                InteractionManager.shared.applySearchHotelsInfo()
                weakSelf?.self.adsIndexSet?.remove(kHotelCardIndex)
                weakSelf?.self.tableManager?.secondManagerPositions = weakSelf?.self.adsIndexSet
                var selectedIndexPath: IndexPath? = weakSelf?.self.tableView?.indexPathForSelectedRow
                if selectedIndexPath?.section >= kHotelCardIndex && selectedIndexPath?.section > 0 {
                    selectedIndexPath = IndexPath(row: 0, section: selectedIndexPath?.section - 1)
                }
                weakSelf?.self.tableView?.reloadData()
                if iPad() && selectedIndexPath {
                    weakSelf?.self.tableView?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: [])
                    weakSelf?.self.tableManager?.tableView(weakSelf?.self.tableView, didSelectRowAt: selectedIndexPath!)
                }
            }
        }
        return hotelCardView!
    }

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        if iPad() {
            setFirstTicketSelected()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isTableViewInsetsDidSet {
            isTableViewInsetsDidSet = true
            setupTableViewInsets()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if iPhone() && tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow, animated: true)
        }
        if isShouldShowMetropolitanResultsInfoAlert {
            isShouldShowMetropolitanResultsInfoAlert = false
            showMetropolitanResultsInfoAlert()
        }
    }

// MARK: - Setup
    func setupViewController() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationItems()
        setupTableView()
    }

    func setupNavigationItems() {
        title = JRSearchInfoUtils.formattedIatasAndDatesExcludeYearComponent(for: searchInfo)
        let showFilters: Selector = #selector(self.showFilters)
        if iPhone() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter_icon"), style: .plain, target: self, action: showFilters as? Selector ?? Selector())
        }
        else {
            parentViewController.navigationItem?.rightBarButtonItem = UIBarButtonItem(title: NSLS("JR_FILTER_BUTTON"), style: .plain, target: self, action: showFilters as? Selector ?? Selector())
        }
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem
    }

    func setupTableView() {
        tableView.dataSource = tableManager
        tableView.delegate = tableManager
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: tableView.sectionHeaderHeight + tableView.sectionFooterHeight))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: tableView.sectionHeaderHeight))
    }

    func setupTableViewInsets() {
        let tableViewInsets: UIEdgeInsets = tableView.contentInset
        let insets: UIEdgeInsets = UIEdgeInsetsMake(tableViewInsets.top(), tableViewInsets.left, (bottomLayoutGuide.characters.count ?? 0), tableViewInsets.right)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

// MARK: - Update
    func setFirstTicketSelected() {
        var indexPath: IndexPath? = nil
        for index in 0..<tableView.numberOfSections {
            indexPath = IndexPath(row: 0, section: index)
            let cell: UITableViewCell? = tableView.cellForRow(at: indexPath!)
            if (cell? is JRResultsTicketCell) {
                break
            }
        }
        if indexPath != nil {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: [])
            tableManager?.tableView(tableView as? UITableView ?? UITableView(), didSelectRowAt: indexPath!)
        }
    }

// MARK: - Alert
    func showMetropolitanResultsInfoAlert() {
        let formattedIATAs: String = JRSearchInfoUtils.formattedIatas(for: searchInfo)
        let message = String(format: NSLS("JR_SEARCH_RESULTS_NON_STRICT_MATCHED_ALERT_MESSAGE"), formattedIATAs)
        showAlert(withTitle: nil, message: message, cancelButtonTitle: NSLS("JR_OK_BUTTON"))
    }

// MARK: - <JRSearchResultsListDelegate>
    func tickets() -> [JRSDKTicket] {
        return filter?.filteredTickets?.array!
    }

    func didSelectTicket(at index: Int) {
        let ticket = tickets()[index] as? JRSDKTicket ?? JRSDKTicket()
        if iPhone() {
            let ticketVC = JRTicketVC(searchInfo: searchInfo, search: response.searchResultInfo?.searchID)
            ticketVC?.ticket = ticket
            navigationController?.pushViewController(ticketVC!, animated: true)
        }
        else {
            if selectionBlock != nil {
                selectionBlock(ticket)
            }
        }
    }

// MARK: - Actions
    func showFilters(_ sender: Any) {
        let mode: JRFilterMode = JRSDKModelUtils.isSimpleSearch(searchInfo) ? JRFilterSimpleSearchMode : JRFilterComplexMode
        let filterVC = JRFilterVC(filter: filter, for: mode, selectedTravelSegment: nil)
        let filtersNavigationVC = JRNavigationController(rootViewController: filterVC)
        if iPad() {
            filtersNavigationVC.modalPresentationStyle = .formSheet
        }
        present(filtersNavigationVC as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

// MARK: - JRFilterDelegate
    func filterDidUpdateFilteredObjects() {
        tableView.reloadData()
        tableView.contentOffset = CGPoint.zero
        let isEmptyResults: Bool = tickets().count == 0
        if filterChangedBlock != nil {
            filterChangedBlock(isEmptyResults)
        }
        if iPad() && !isEmptyResults {
            setFirstTicketSelected()
        }
    }
}