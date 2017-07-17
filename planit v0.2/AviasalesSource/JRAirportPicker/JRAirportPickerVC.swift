//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAirportPickerVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

let kJRAirportPickerMaxSearchedCount = (iPhone() ? 5 : 10)
let kJRAirportPickerHeightForTitledHeader = 44
let kJRAirportPickerHeightForUntitledHeader = 10
let kJRAirportPicketHeightForRow = 60
let kJRAirportPickerBottomLineOffset = 20
let kJRAirportPickerMaxSearchedAirportListSize = (iPhone() ? 7 : 15)
private let kJRAirportPickerCellWithInfo: String = "JRAirportPickerCellWithInfo"
private let kJRAirportPickerCellWithAirport: String = "JRAirportPickerCellWithAirport"

class JRAirportPickerVC: JRViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var mode = JRAirportPickerMode()
    var travelSegmentBuilder: JRSDKTravelSegmentBuilder?
    var sections = [[JRAirportPickerItem]]()
    var sectionTitles = [AnyHashable: Any]()
    var searchString: String = ""
    var selectionBlock: ((_: JRSDKAirport) -> Void)? = nil
    var searchController: UISearchController?

    init(mode: JRAirportPickerMode, selectionBlock: @escaping (_: JRSDKAirport) -> Void) {
        super.init()
        
        self.mode = mode
        self.selectionBlock = selectionBlock
    
    }

    func setupTitle() {
        var title: String? = nil
        if mode == JRAirportPickerOriginMode {
            title = NSLS("JR_AIRPORT_PICKER_ORIGIN_MODE_TITLE")
        }
        else if mode == JRAirportPickerDestinationMode {
            title = NSLS("JR_AIRPORT_PICKER_DESTINATION_MODE_TITLE")
        }

        self.title = title
    }

    func setupSearchController() {
        weak var weakSelf: JRAirportPickerVC? = self
        let airportSearchResultVC = JRAirportSearchResultVC(selectionBlock: {(_ item: JRAirportPickerItem) -> Void in
                weakSelf?.performSelection(item)
            })
        let searchController = UISearchController(searchResultsController: airportSearchResultVC as? UIViewController)
        searchController?.searchResultsUpdater = airportSearchResultVC
        searchController?.searchBar?.placeholder = NSLS("JR_AIRPORT_PICKER_PLACEHOLDER_TEXT")
        tableView.tableHeaderView = searchController?.searchBar
        self.searchController = searchController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupTitle()
        setupSearchController()
        buildSections()
        if mode == JRAirportPickerOriginMode {
            NotificationCenter.default.addObserver(self, selector: #selector(self.rebuildTableView), name: kAviasalesNearestAirportsManagerDidUpdateNotificationName, object: nil)
        }
    }

    deinit {
        searchController?.view?.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - Build
    func addNearestAirportsSection() {
        var nearestAirportsSection = [Any]()
        let nearestAirportsSectionTitle: String = NSLS("JR_AIRPORT_PICKER_NEAREST_AIRPORTS")
        let nearestAirports: [Any] = AviasalesSDK.sharedInstance.nearestAirports().airports()
        let status: AviasalesNearestAirportsManagerStatus = AviasalesSDK.sharedInstance.nearestAirports().state
        if status == AviasalesNearestAirportsManagerIdle && nearestAirports.count == 0 {
            let noNearbyItem = JRAirportPickerItem()
            noNearbyItem.cellIdentifier = kJRAirportPickerCellWithInfo
            noNearbyItem.itemContent = NSLS("JR_AIRPORT_PICKER_NO_NEAREST_AIRPORTS")
            nearestAirportsSection.append(noNearbyItem)
        }
        else if status == AviasalesNearestAirportsManagerReadingAirportData {
            let updatingItem = JRAirportPickerItem()
            updatingItem.cellIdentifier = kJRAirportPickerCellWithInfo
            updatingItem.itemContent = NSLS("JR_AIRPORT_PICKER_UPDATING_NEAREST_AIRPORTS")
            nearestAirportsSection.append(updatingItem)
        }
        else if status == AviasalesNearestAirportsManagerReadingError {
            let readingErrorItem = JRAirportPickerItem()
            readingErrorItem.cellIdentifier = kJRAirportPickerCellWithInfo
            readingErrorItem.itemContent = NSLS("JR_AIRPORT_PICKER_NEAREST_AIRPORTS_READING_ERROR")
            nearestAirportsSection.append(readingErrorItem)
        }
        else {
            for airport: JRSDKAirport in nearestAirports {
                let airportItem = JRAirportPickerItem()
                airportItem.cellIdentifier = kJRAirportPickerCellWithAirport
                airportItem.itemContent = airport
                nearestAirportsSection.append(airportItem)
            }
        }

        if nearestAirportsSection.count > 0 {
            sections?.append(nearestAirportsSection)
            let sectionKey: String = "\(sections? as NSArray).index(of: nearestAirportsSection)"
            sectionTitles[sectionKey] = nearestAirportsSectionTitle
        }
    }

    func addSearchedAirportsSection() {
        let searchedAirports: [Any] = JRSearchedAirportsManager.searchedAirports()
        var searchedAirportsSection = [Any]()
        let searchedAirportsSectionTitle: String = NSLS("JR_AIRPORT_PICKER_SEARCHED_AIRPORTS")
        let numberOfSearchedAirports: Int = 0
        for airport: JRSDKAirport in searchedAirports {
            let airportItem = JRAirportPickerItem()
            airportItem.cellIdentifier = kJRAirportPickerCellWithAirport
            airportItem.itemContent = airport
            searchedAirportsSection.append(airportItem)
            numberOfSearchedAirports += 1
            if numberOfSearchedAirports >= kJRAirportPickerMaxSearchedAirportListSize {
                break
            }
        }
        if searchedAirportsSection.count > 0 {
            sections?.append(searchedAirportsSection)
            let sectionKey: String = "\(sections? as NSArray).index(of: searchedAirportsSection)"
            sectionTitles[sectionKey] = searchedAirportsSectionTitle
        }
    }

    func buildSections() {
        sections = [Any]()
        sectionTitles = [AnyHashable: Any]()
        if mode == JRAirportPickerOriginMode {
            addNearestAirportsSection()
        }
        addSearchedAirportsSection()
    }

    func rebuildTableView() {
        buildSections()
        tableView.reloadData()
    }

// MARK: - Selection
    func performSelection(_ item: JRAirportPickerItem) {
        let object: Any? = item.itemContent
        if (object? is JRSDKAirport) {
            let airport: JRSDKAirport? = object
            JRSearchedAirportsManager.markSearchedAirport(airport)
            if selectionBlock {
                selectionBlock(airport)
            }
            popOrDismissBasedOnDeviceTypeWith(animated: true)
        }
    }

// MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: JRAirportPickerItem? = sections[indexPath.section][indexPath.row]
        var cell: Any? = tableView.dequeueReusableCell(withIdentifier: item?.cellIdentifier)
        if cell == nil {
            cell = LOAD_VIEW_FROM_NIB_NAMED(item?.cellIdentifier)
        }
        cell?.leftOffset = kJRAirportPickerBottomLineOffset
        cell?.bottomLineVisible = true
        if (cell? is JRAirportPickerCellWithInfo) {
            cell?.locationInfoLabel()?.text = item?.itemContent?.uppercased()
            let shouldHideActivityIndicator: Bool? = self.tableView == tableView && !(item?.itemContent == NSLS("JR_AIRPORT_PICKER_UPDATING_NEAREST_AIRPORTS"))
            let shouldEnableSelection: Bool? = (item?.itemContent == NSLS("JR_AIRPORT_PICKER_NEAREST_AIRPORTS_UPDATING_ERROR"))
            cell?.selectionStyle = shouldEnableSelection ? .default : []
            shouldHideActivityIndicator ? cell?.stopActivityIndicator() : cell?.startActivityIndicator()
        }
        if (cell? is JRAirportPickerCellWithAirport) {
            cell?.search = searchString
            cell?.airport = item?.itemContent
        }
        cell?.updateBackgroundViews(forImagePath: indexPath, in: tableView)
        return cell!
    }

// MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item: JRAirportPickerItem? = sections[indexPath.section][indexPath.row]
        performSelection(item)
    }

    func mainViewForHeader(inSection section: Int) -> UIView? {
        let sectionKey: String = "\(section)"
        let title: String = sectionTitles[sectionKey]
        if title != "" {
            let header: JRAirportPickerSectionTitle? = LOAD_VIEW_FROM_NIB_NAMED("JRAirportPickerSectionTitle")
            header?.titleLabel?.text = title as? String
            header?.backgroundColor = UIColor.clear
            return header!
        }
        else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return mainViewForHeader(inSection: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionKey: String = "\(section)"
        let title: String = sectionTitles[sectionKey]
        return title ? kJRAirportPickerHeightForTitledHeader : kJRAirportPickerHeightForUntitledHeader
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kJRAirportPicketHeightForRow
    }
}