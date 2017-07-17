//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterCellsFactory.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

private let kDefaultCellHeight: CGFloat = 50.0
private let kTravelSegmentCellHeight: CGFloat = 65.0
private let kSlidersCellSmallHeight: CGFloat = 90.0
private let kSlidersCellBigHeight: CGFloat = 120.0
private let kListSeparatorCellHeight: CGFloat = 20.0
private let kHeaderHeight: CGFloat = 20.0

class JRFilterCellsFactory: NSObject {
    var tableView: UITableView?
    var mode = JRFilterMode()

    init(tableView: UITableView, with mode: JRFilterMode) {
        super.init()
        
        self.tableView = tableView
        self.mode = mode
        registerNibs()
    
    }

    func cell(byItem item: JRFilterItemProtocol) -> UITableViewCell {
        var cell = UITableViewCell()
        if (item is JRFilterTravelSegmentItem) {
            let travelSegmentCell: JRFilterTravelSegmentCell? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterTravelSegmentCell") as? JRFilterTravelSegmentCell)
            travelSegmentCell?.item = (item as? JRFilterTravelSegmentItem)
            cell = travelSegmentCell
        }
        else if (item is JRFilterOneThumbSliderItem) {
            let oneThumbCell: JRFilterCellWithOneThumbSlider? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterCellWithOneThumbSlider") as? JRFilterCellWithOneThumbSlider)
            oneThumbCell?.item = (item as? JRFilterOneThumbSliderItem)
            cell = oneThumbCell
        }
        else if (item is JRFilterTwoThumbSliderItem) {
            let twoThumbCell: JRFilterCellWithTwoThumbsSlider? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterCellWithTwoThumbsSlider") as? JRFilterCellWithTwoThumbsSlider)
            twoThumbCell?.item = (item as? JRFilterTwoThumbSliderItem)
            cell = twoThumbCell
        }
        else if (item is JRFilterCheckBoxItem) {
            let checkItem: JRFilterCheckboxCell? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterCheckboxCell") as? JRFilterCheckboxCell)
            checkItem?.item = (item as? JRFilterCheckBoxItem)
            cell = checkItem
        }
        else if (item is JRFilterListHeaderItem) {
            let headerItem: JRFilterListHeaderCell? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterListHeaderCell") as? JRFilterListHeaderCell)
            headerItem?.item = (item as? JRFilterListHeaderItem)
            cell = headerItem
        }
        else if (item is JRFilterListSeparatorItem) {
            let separatorCell: JRFilterListSeparatorCell? = (tableView.dequeueReusableCell(withIdentifier: "JRFilterListSeparatorCell") as? JRFilterListSeparatorCell)
            separatorCell?.item = (item as? JRFilterListSeparatorItem)
            cell = separatorCell
        }

        return cell
    }

    func heightForCell(byItem item: JRFilterItemProtocol) -> CGFloat {
        var height: CGFloat = kDefaultCellHeight
        if (item is JRFilterTravelSegmentItem) {
            height = kTravelSegmentCellHeight
        }
        else if (item is JRFilterOneThumbSliderItem) {
            height = kSlidersCellSmallHeight
        }
        else if (item is JRFilterDelaysDurationItem) {
            height = kSlidersCellSmallHeight
        }
        else if (item is JRFilterArrivalTimeItem) {
            height = kSlidersCellSmallHeight
        }
        else if (item is JRFilterDepartureTimeItem) {
            height = kSlidersCellBigHeight
        }
        else if (item is JRFilterListSeparatorItem) {
            height = kListSeparatorCellHeight
        }

        return height
    }

    func heightForHeader() -> CGFloat {
        return kHeaderHeight
    }

// MARK: - Private methds
    func registerNibs() {
        let oneThumbSliderNib = UINib(nibName: "JRFilterCellWithOneThumbSlider", bundle: AVIASALES_BUNDLE)
        tableView.register(oneThumbSliderNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterCellWithOneThumbSlider")
        let twoThumbSliderNib = UINib(nibName: "JRFilterCellWithTwoThumbsSlider", bundle: AVIASALES_BUNDLE)
        tableView.register(twoThumbSliderNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterCellWithTwoThumbsSlider")
        let checkboxNib = UINib(nibName: "JRFilterCheckboxCell", bundle: AVIASALES_BUNDLE)
        tableView.register(checkboxNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterCheckboxCell")
        let headerNib = UINib(nibName: "JRFilterListHeaderCell", bundle: AVIASALES_BUNDLE)
        tableView.register(headerNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterListHeaderCell")
        let travelSegmentNib = UINib(nibName: "JRFilterTravelSegmentCell", bundle: AVIASALES_BUNDLE)
        tableView.register(travelSegmentNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterTravelSegmentCell")
        let listSeparatorNib = UINib(nibName: "JRFilterListSeparatorCell", bundle: AVIASALES_BUNDLE)
        tableView.register(listSeparatorNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFilterListSeparatorCell")
    }
}