//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormPresenter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

enum ASTComplexSearchFormCellSegmentType : Int {
    case origin
    case destination
    case departure
}

private let kComplexSearchInfoBuilderStorageKey: String = "complexSearchInfoBuilderStorageKey"
private let minTravelSegments: Int = 1
private let maxTravelSegments: Int = 8

class ASTComplexSearchFormPresenter: NSObject {
    weak var viewController: ASTComplexSearchFormViewControllerProtocol?
    var searchInfoBuilder: JRSDKSearchInfoBuilder?
    var travelSegmentBuilders: NSMutableOrderedSet<JRSDKTravelSegmentBuilder>?

    init(viewController: ASTComplexSearchFormViewControllerProtocol) {
        super.init()
        
        self.viewController = viewController
    
    }

    func handleViewDidLoad() {
        restoreSearchInfoBuilder()
        createTravelSegmentBuilders()
        viewController.update(withViewModel: buildViewModel())
    }

    func handleSelectCellSegment(with type: ASTComplexSearchFormCellSegmentType, at index: Int) {
        switch type {
            case .origin:
                viewController.showAirportPicker(with: JRAirportPickerOriginMode, for: index)
            case .destination:
                viewController.showAirportPicker(with: JRAirportPickerDestinationMode, for: index)
            case .departure:
                viewController.showDatePicker(withBorderDate: borderDate(at: index), selectedDate: departureDate(at: index), for: index)
        }

    }

    func handleAddTravelSegment() {
        let index: Int? = travelSegmentBuilders?.count
        travelSegmentBuilders?.append(JRSDKTravelSegmentBuilder())
        viewController.addRowAnimated(at: index, withViewModel: buildViewModel())
    }

    func handleRemoveTravelSegment() {
        travelSegmentBuilders?.remove(at: travelSegmentBuilders?.index(of: travelSegmentBuilders?.last)!)
        let index: Int? = travelSegmentBuilders?.count
        viewController.removeRowAnimated(at: index, withViewModel: buildViewModel())
    }

    func handlePickPassengers() {
        viewController.showPassengersPicker(withInfo: buildPassengersInfo())
    }

    func handleSelect(_ selectedAirport: JRSDKAirport, with mode: JRAirportPickerMode, at index: Int) {
        if travelSegmentBuilders?.count > index {
            switch mode {
                case JRAirportPickerOriginMode:
                    travelSegmentBuilders[index].originAirport = selectedAirport
                case JRAirportPickerDestinationMode:
                    travelSegmentBuilders[index].destinationAirport = selectedAirport
            }

            viewController.update(withViewModel: buildViewModel())
        }
    }

    func handleSelect(_ selectedDate: Date, at index: Int) {
        if travelSegmentBuilders?.count > index {
            travelSegmentBuilders[index].departureDate = selectedDate
            updateDates(from: index, with: selectedDate)
            viewController.update(withViewModel: buildViewModel())
        }
    }

    func handleSelect(_ selectedPassengersInfo: ASTPassengersInfo) {
        searchInfoBuilder?.adults = selectedPassengersInfo.adults
        searchInfoBuilder?.children = selectedPassengersInfo.children
        searchInfoBuilder?.infants = selectedPassengersInfo.infants
        searchInfoBuilder?.travelClass = selectedPassengersInfo.travelClass
        viewController.update(withViewModel: buildViewModel())
    }

    func handleSearch() {
        let searchInnfo: JRSDKSearchInfo? = buildSearchInfo()
        if searchInnfo != nil {
            viewController.showWaitingScreen(with: searchInnfo)
            saveSearchInfoBuilder()
            InteractionManager.shared.clearSearchHotelsInfo()
        }
    }

// MARK: - Build
    func buildPassengersInfo() -> ASTPassengersInfo {
        let adults: Int? = searchInfoBuilder?.adults
        let children: Int? = searchInfoBuilder?.children
        let infants: Int? = searchInfoBuilder?.infants
        let travelClass: JRSDKTravelClass? = searchInfoBuilder?.travelClass
        return ASTPassengersInfo(adults: adults, children: children, infants: infants, travelClass: travelClass)
    }

    func buildViewModel() -> ASTComplexSearchFormViewModel {
        let viewModel = ASTComplexSearchFormViewModel()
        viewModel.cellViewModels = buildCellViewModels()
        viewModel.footerViewModel = buildFooterViewModel()
        viewModel.passengersViewModel = buildPassengersViewModel()
        return viewModel
    }

    func buildCellViewModels() -> [ASTComplexSearchFormCellViewModel] {
        var cellViewModels: [ASTComplexSearchFormCellViewModel]? = [Any]() /* capacity: travelSegmentBuilders?.count */
        weak var weakSelf: ASTComplexSearchFormPresenter? = self
        travelSegmentBuilders?.bk_each({(_ travelSegmentBuilder: JRSDKTravelSegmentBuilder) -> Void in
            cellViewModels?.append(weakSelf?.buildCellViewModel(from: travelSegmentBuilder))
        })
        return cellViewModels!
    }

    func buildCellViewModel(from travelSegmentBuilder: JRSDKTravelSegmentBuilder) -> ASTComplexSearchFormCellViewModel {
        var cellViewModel = ASTComplexSearchFormCellViewModel()
        cellViewModel.origin = buildCellSegmentViewModel(from: travelSegmentBuilder.originAirport, icon: "origin_icon")
        cellViewModel.destination = buildCellSegmentViewModel(from: travelSegmentBuilder.destinationAirport, icon: "destination_icon")
        cellViewModel.departure = buildCellSegmentViewModel(from: travelSegmentBuilder.departureDate, icon: "departure_icon")
        return cellViewModel
    }

    func buildCellSegmentViewModel(from airport: JRSDKAirport, icon: String) -> ASTComplexSearchFormCellSegmentViewModel {
        let cellSegmentViewModel = ASTComplexSearchFormCellSegmentViewModel()
        cellSegmentViewModel.placeholder = airport == nil
        cellSegmentViewModel.icon = icon
        cellSegmentViewModel.title = airport.iata
        cellSegmentViewModel.subtitle = airport.city
        return cellSegmentViewModel
    }

    func buildCellSegmentViewModel(from date: Date, icon: String) -> ASTComplexSearchFormCellSegmentViewModel {
        let cellSegmentViewModel = ASTComplexSearchFormCellSegmentViewModel()
        cellSegmentViewModel.placeholder = date == nil
        cellSegmentViewModel.icon = icon
        cellSegmentViewModel.title = DateUtil.dayMonthString(from: date)
        cellSegmentViewModel.subtitle = DateUtil.date(toYearString: date)
        return cellSegmentViewModel
    }

    func buildFooterViewModel() -> ASTComplexSearchFormFooterViewModel {
        let viewModel = ASTComplexSearchFormFooterViewModel()
        viewModel.shouldEnableAdd = travelSegmentBuilders?.count < maxTravelSegments
        viewModel.shouldEnableRemove = travelSegmentBuilders?.count > minTravelSegments
        return viewModel
    }

    func buildPassengersViewModel() -> ASTComplexSearchFormPassengersViewModel {
        let viewModel = ASTComplexSearchFormPassengersViewModel()
        viewModel.adults = "\(searchInfoBuilder?.adults)"
        viewModel.children = "\(searchInfoBuilder?.children)"
        viewModel.infants = "\(searchInfoBuilder?.infants)"
        viewModel.travelClass = JRSearchInfoUtils.travelClassString(withTravel: searchInfoBuilder?.travelClass)
        return viewModel
    }

// MARK: - Restore & Create & Save
    func restoreSearchInfoBuilder() {
        let data: Data? = UserDefaults.standard.object(forKey: kComplexSearchInfoBuilderStorageKey)
        var searchInfoBuilder: JRSDKSearchInfoBuilder? = NSKeyedUnarchiver.unarchiveObject(with: data!)
        if searchInfoBuilder == nil {
            searchInfoBuilder = createSearchInfoBuilder()
        }
        self.searchInfoBuilder = searchInfoBuilder
    }

    func createSearchInfoBuilder() -> JRSDKSearchInfoBuilder {
        let searchInfoBuilder = JRSDKSearchInfoBuilder()
        searchInfoBuilder.adults = 1
        return searchInfoBuilder
    }

    func createTravelSegmentBuilders() {
        let travelSegmentBuilders: NSOrderedSet<JRSDKTravelSegmentBuilder>? = searchInfoBuilder.travelSegments.bk_map({(_ travelSegment: JRSDKTravelSegment) -> Any in
                return JRSDKTravelSegmentBuilder(travelSegment: travelSegment)
            })
        self.travelSegmentBuilders = travelSegmentBuilders?.count ? travelSegmentBuilders? : NSMutableOrderedSet(objects: JRSDKTravelSegmentBuilder(), nil)
    }

    func saveSearchInfoBuilder() {
        let data = NSKeyedArchiver.archivedData(withRootObject: searchInfoBuilder)
        UserDefaults.standard.set(data, forKey: kComplexSearchInfoBuilderStorageKey)
        UserDefaults.standard.synchronize()
    }

// MARK: - Logic
    func borderDate(at index: Int) -> Date {
        var result: Date? = nil
        if travelSegmentBuilders?.count > index && index > 0 {
            result = travelSegmentBuilders[index - 1].departureDate
        }
        return result!
    }

    func departureDate(at index: Int) -> Date {
        var result: Date? = nil
        if travelSegmentBuilders?.count > index {
            result = travelSegmentBuilders[index].departureDate
        }
        return result!
    }

    func updateDates(from index: Int, with date: Date) {
        for i in index..<travelSegmentBuilders?.count {
            let travelSegmentBuilder: JRSDKTravelSegmentBuilder? = travelSegmentBuilders[i]
            if travelSegmentBuilder?.departureDate && travelSegmentBuilder?.departureDate < date {
                travelSegmentBuilder?.departureDate = date
            }
        }
    }

    func validateTravelSegmentBuilders() -> String {
        var result: String? = nil
        for travelSegmentBuilder: JRSDKTravelSegmentBuilder in travelSegmentBuilders {
            result = validate(travelSegmentBuilder)
            if result != nil {
                break
            }
        }
        return result!
    }

    func validate(_ travelSegmentBuilder: JRSDKTravelSegmentBuilder) -> String {
        let originMainIATA: JRSDKIATA = AviasalesSDK.sharedInstance.airportsStorage.mainIATA(byIATA: travelSegmentBuilder.originAirport.iata)
        let destinationMainIATA: JRSDKIATA = AviasalesSDK.sharedInstance.airportsStorage.mainIATA(byIATA: travelSegmentBuilder.destinationAirport.iata)
        var result: String? = nil
        if !travelSegmentBuilder.originAirport {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_ORIGIN_ERROR")
        }
        else if !travelSegmentBuilder.destinationAirport {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_DESTINATION_ERROR")
        }
        else if (originMainIATA == destinationMainIATA) {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_SAME_CITY_ERROR")
        }
        else if !travelSegmentBuilder.departureDate {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_DEPARTURE_DATE")
        }

        return result!
    }

    func buildTravelSegments() {
        searchInfoBuilder.travelSegments = travelSegmentBuilders?.bk_map({(_ travelSegmentBuilder: JRSDKTravelSegmentBuilder) -> Any in
            return travelSegmentBuilder.build()
        })
    }

    func buildSearchInfo() -> JRSDKSearchInfo {
        var result: JRSDKSearchInfo? = nil
        let error: String = validateTravelSegmentBuilders()
        if error != "" {
            try? viewController.showError()
        }
        else {
            buildTravelSegments()
            result = searchInfoBuilder.build()
        }
        return result!
    }
}