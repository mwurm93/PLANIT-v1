//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAirportSearchResultVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRAirportSearchResultVC: UIViewController, UISearchResultsUpdating, AviasalesSearchPerformerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var airportsSearchPerformer: AviasalesAirportsSearchPerformer?
    var searchString: String = ""
    var searchResults = [JRSDKLocation]()
    var items = [JRAirportPickerItem]()
    var isSearching: Bool = false
    var selectionBlock: ((_: JRAirportPickerItem) -> Void)? = nil

    init(selectionBlock: @escaping (_: JRAirportPickerItem) -> Void) {
        super.init()
        
        self.selectionBlock = selectionBlock
    
    }

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

// MARK: - Setup
    func setupViewController() {
        setupAirportsSearchPerformer()
    }

    func setupAirportsSearchPerformer() {
        let searchTypes: APISearchLocationType = APISearchLocationTypeAirport | APISearchLocationTypeCity
        let airportsSearchPerformer = AviasalesAirportsSearchPerformer(searchLocationType: searchTypes, delegate: self)
        self.airportsSearchPerformer = airportsSearchPerformer
    }

// MARK: - Build
    func buildItems() -> [JRAirportPickerItem] {
        var items: [JRAirportPickerItem] = [Any]()
        for location: JRSDKLocation in searchResults {
            if (location is JRSDKAirport) {
                let airport: JRSDKAirport? = (location as? JRSDKAirport)
                if airport?.isSearchable {
                    let airportItem = JRAirportPickerItem()
                    airportItem.cellIdentifier = "JRAirportPickerCellWithAirport"
                    airportItem.itemContent = airport
                    items.append(airportItem)
                }
            }
        }
        if isSearching {
            let searchingItem = JRAirportPickerItem()
            searchingItem.cellIdentifier = "JRAirportPickerCellWithInfo"
            searchingItem.itemContent = NSLS("JR_AIRPORT_PICKER_SEARCHING_ON_SERVER_TEXT")
            items.append(searchingItem)
        }
        return items
    }

// MARK: - AviasalesSearchPerformerDelegate
    func airportsSearchPerformer(_ airportsSearchPerformer: AviasalesAirportsSearchPerformer, didFoundLocations locations: [JRSDKLocation], final `final`: Bool) {
        isSearching = !`final`
        searchResults = locations
        items = buildItems()
        tableView.reloadData()
    }

// MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchString = searchController.searchBar.text
        isSearching = true
        airportsSearchPerformer.searchAirports(with: searchController.searchBar.text)
    }

// MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: JRAirportPickerItem? = items()[indexPath.row]
        var cell: Any? = tableView.dequeueReusableCell(withIdentifier: item?.cellIdentifier)
        if cell == nil {
            cell = LOAD_VIEW_FROM_NIB_NAMED(item?.cellIdentifier)
        }
        if (cell? is JRAirportPickerCellWithInfo) {
            cell?.locationInfoLabel()?.text = item?.itemContent?.uppercased()
        }
        else if (cell? is JRAirportPickerCellWithAirport) {
            cell?.search = searchString
            cell?.airport = item?.itemContent
        }

        cell?.updateBackgroundViews(forImagePath: indexPath, in: tableView)
        return cell!
    }

// MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectionBlock {
            selectionBlock(items()[indexPath.row])
        }
    }
}