//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormPresenter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

private let kSimpleSearchInfoBuilderStorageKey: String = "simpleSearchInfoBuilderStorageKey"

class ASTSimpleSearchFormPresenter: NSObject {
    weak var viewController: ASTSimpleSearchFormViewControllerProtocol?
    var searchInfoBuilder: JRSDKSearchInfoBuilder?
    var directTravelSegmentBuilder: JRSDKTravelSegmentBuilder?
    var returnDate: Date?
    var isShouldSetReturnDate: Bool = false

    init(viewController: ASTSimpleSearchFormViewControllerProtocol) {
        super.init()
        
        self.viewController = viewController
    
    }

    func updateSearchInfo(withDestination destination: JRSDKAirport, checkIn: Date, checkOut: Date, passengers: ASTPassengersInfo) {
        directTravelSegmentBuilder?.destinationAirport = destination
        directTravelSegmentBuilder?.departureDate = checkIn
        returnDate = checkOut
        isShouldSetReturnDate = true
        searchInfoBuilder?.adults = passengers.adults
        searchInfoBuilder?.infants = passengers.infants
        searchInfoBuilder?.children = passengers.children
        viewController.update(withViewModel: buildViewModel())
    }

    func handleViewDidLoad() {
        restoreSearchInfoBuilder()
        createDirectTravelSegmentBuilder()
        viewController.update(withViewModel: buildViewModel())
    }

    func handleSelect(_ cellViewModel: ASTSimpleSearchFormCellViewModel) {
        switch cellViewModel.type {
            case ASTSimpleSearchFormCellViewModelTypeOrigin:
                viewController.showAirportPicker(with: JRAirportPickerOriginMode)
            case ASTSimpleSearchFormCellViewModelTypeDestination:
                viewController.showAirportPicker(with: JRAirportPickerDestinationMode)
            case ASTSimpleSearchFormCellViewModelTypeDeparture:
                viewController.showDatePicker(withMode: JRDatePickerModeDeparture, borderDate: nil, firstDate: directTravelSegmentBuilder?.departureDate, secondDate: isShouldSetReturnDate ? returnDate : nil)
            case ASTSimpleSearchFormCellViewModelTypeReturn:
                viewController.showDatePicker(withMode: JRDatePickerModeReturn, borderDate: directTravelSegmentBuilder?.departureDate, firstDate: directTravelSegmentBuilder?.departureDate, secondDate: isShouldSetReturnDate ? returnDate : nil)
        }

    }

    func handlePickPassengers() {
        viewController.showPassengersPicker(withInfo: buildPassengersInfo())
    }

    func handleSelect(_ selectedAirport: JRSDKAirport, with mode: JRAirportPickerMode) {
        switch mode {
            case JRAirportPickerOriginMode:
                directTravelSegmentBuilder?.originAirport = selectedAirport
            case JRAirportPickerDestinationMode:
                directTravelSegmentBuilder?.destinationAirport = selectedAirport
        }

        viewController.update(withViewModel: buildViewModel())
    }

    func handleSelect(_ selectedDate: Date, with mode: JRDatePickerMode) {
        switch mode {
            case JRDatePickerModeDeparture:
                directTravelSegmentBuilder?.departureDate = selectedDate
                if returnDate && selectedDate > returnDate {
                    returnDate = selectedDate
                }
            case JRDatePickerModeReturn:
                isShouldSetReturnDate = true
                returnDate = selectedDate
            default:
                break
        }

        viewController.update(withViewModel: buildViewModel())
    }

    func handleSelect(_ selectedPassengersInfo: ASTPassengersInfo) {
        searchInfoBuilder?.adults = selectedPassengersInfo.adults
        searchInfoBuilder?.children = selectedPassengersInfo.children
        searchInfoBuilder?.infants = selectedPassengersInfo.infants
        searchInfoBuilder?.travelClass = selectedPassengersInfo.travelClass
        viewController.update(withViewModel: buildViewModel())
    }

    func handleSwapAirports() {
        let originAirport: JRSDKAirport? = directTravelSegmentBuilder?.originAirport
        directTravelSegmentBuilder?.originAirport = directTravelSegmentBuilder?.destinationAirport
        directTravelSegmentBuilder?.destinationAirport = originAirport
        viewController.update(withViewModel: buildViewModel())
    }

    func handleSwitchReturnCheckbox() {
        if isShouldSetReturnDate {
            isShouldSetReturnDate = false
            viewController.update(withViewModel: buildViewModel())
        }
        else {
            if returnDate != nil {
                isShouldSetReturnDate = true
                viewController.update(withViewModel: buildViewModel())
            }
            else {
                viewController.showDatePicker(withMode: JRDatePickerModeReturn, borderDate: directTravelSegmentBuilder?.departureDate, firstDate: directTravelSegmentBuilder?.departureDate, secondDate: returnDate)
            }
        }
    }

    func handleSearch() {
        let searchInfo: JRSDKSearchInfo? = buildSearchInfo()
        if searchInfo != nil {
            viewController.showWaitingScreen(with: searchInfo)
            saveSearchInfoBuilder()
            InteractionManager.shared.prepareSearchHotelsInfo(from: searchInfo)
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

    func buildViewModel() -> ASTSimpleSearchFormViewModel {
        let viewModel = ASTSimpleSearchFormViewModel()
        viewModel.sectionViewModels = buildSectionViewModels()
        viewModel.passengersViewModel = buildPassengersViewModel()
        return viewModel
    }

    func buildSectionViewModels() -> [ASTSimpleSearchFormSectionViewModel] {
        return [buildAirportsSectionViewModel(), buildDatesSectionViewModel()]
    }

    func buildPassengersViewModel() -> ASTSimpleSearchFormPassengersViewModel {
        let passengersViewModel = ASTSimpleSearchFormPassengersViewModel()
        passengersViewModel.adults = "\(searchInfoBuilder?.adults)"
        passengersViewModel.children = "\(searchInfoBuilder?.children)"
        passengersViewModel.infants = "\(searchInfoBuilder?.infants)"
        passengersViewModel.travelClass = JRSearchInfoUtils.travelClassString(withTravel: searchInfoBuilder?.travelClass)
        return passengersViewModel
    }

    func buildAirportsSectionViewModel() -> ASTSimpleSearchFormSectionViewModel {
        let travelSegmentBuilder: JRSDKTravelSegmentBuilder? = directTravelSegmentBuilder
        let sectionViewModel = ASTSimpleSearchFormSectionViewModel()
        sectionViewModel.cellViewModels = [buildAirportCellViewModel(withType: ASTSimpleSearchFormCellViewModelTypeOrigin, airport: travelSegmentBuilder?.originAirport), buildAirportCellViewModel(withType: ASTSimpleSearchFormCellViewModelTypeDestination, airport: travelSegmentBuilder?.destinationAirport)]
        return sectionViewModel
    }

    func buildDatesSectionViewModel() -> ASTSimpleSearchFormSectionViewModel {
        let directDate: Date? = directTravelSegmentBuilder?.departureDate
        let returnDate: Date? = isShouldSetReturnDate ? self.returnDate : nil
        let sectionViewModel = ASTSimpleSearchFormSectionViewModel()
        sectionViewModel.cellViewModels = [buildDateCellViewModel(withType: ASTSimpleSearchFormCellViewModelTypeDeparture, date: directDate), buildDateCellViewModel(withType: ASTSimpleSearchFormCellViewModelTypeReturn, date: returnDate)]
        return sectionViewModel
    }

    func buildAirportCellViewModel(with type: ASTSimpleSearchFormCellViewModelType, airport: JRSDKAirport) -> ASTSimpleSearchFormAirportCellViewModel {
        let cellViewModel = ASTSimpleSearchFormAirportCellViewModel()
        cellViewModel.type = type
        let isOrigin: Bool = type == ASTSimpleSearchFormCellViewModelTypeOrigin
        let placeholder: String = isOrigin ? "JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_ORIGIN" : "JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_DESTINATION"
        cellViewModel.city = airport.city ? airport.city : NSLS(placeholder)
        cellViewModel.iata = airport.iata
        cellViewModel.icon = isOrigin ? "origin_icon" : "destination_icon"
        cellViewModel.hint = isOrigin ? NSLS("JR_SEARCH_FORM_COMPLEX_ORIGIN") : NSLS("JR_SEARCH_FORM_COMPLEX_DESTINATION")
        cellViewModel.placeholder = !airport.city
        return cellViewModel
    }

    func buildDateCellViewModel(with type: ASTSimpleSearchFormCellViewModelType, date: Date) -> ASTSimpleSearchFormDateCellViewModel {
        let cellViewModel = ASTSimpleSearchFormDateCellViewModel()
        cellViewModel.type = type
        let isDeparture: Bool = type == ASTSimpleSearchFormCellViewModelTypeDeparture
        let placeholder: String = isDeparture ? "JR_DATE_PICKER_DEPARTURE_DATE_TITLE" : "JR_DATE_PICKER_RETURN_DATE_TITLE"
        cellViewModel.date = date ? DateUtil.dayMonthYearWeekdayString(from: date) : NSLS(placeholder)
        cellViewModel.icon = isDeparture ? "departure_icon" : "arrival_icon"
        cellViewModel.hint = isDeparture ? NSLS("JR_SEARCH_FORM_SIMPLE_SEARCH_DEPARTURE_DATE") : NSLS("JR_SEARCH_FORM_SIMPLE_SEARCH_RETURN_DATE")
        cellViewModel.shouldHideReturnCheckbox = isDeparture
        cellViewModel.shouldSelectReturnCheckbox = date != nil
        cellViewModel.placeholder = !date
        return cellViewModel
    }

// MARK: - Restore & Create & Save
    func restoreSearchInfoBuilder() {
        let data: Data? = UserDefaults.standard.object(forKey: kSimpleSearchInfoBuilderStorageKey)
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

    func createDirectTravelSegmentBuilder() {
        let directTravelSegment: JRSDKTravelSegment? = searchInfoBuilder.travelSegments.first
        let returnTravelSegment: JRSDKTravelSegment? = searchInfoBuilder.travelSegments.last
        if directTravelSegment != nil {
            directTravelSegmentBuilder = JRSDKTravelSegmentBuilder(travelSegment: directTravelSegment)
        }
        else {
            directTravelSegmentBuilder = JRSDKTravelSegmentBuilder()
        }
        if directTravelSegment && returnTravelSegment && !directTravelSegment?.isEqual(returnTravelSegment) {
            returnDate = returnTravelSegment?.departureDate
            isShouldSetReturnDate = true
        }
    }

    func saveSearchInfoBuilder() {
        let data = NSKeyedArchiver.archivedData(withRootObject: searchInfoBuilder)
        UserDefaults.standard.set(data, forKey: kSimpleSearchInfoBuilderStorageKey)
        UserDefaults.standard.synchronize()
    }

// MARK: - Logic
    func validateTravelSegmentBuilder() -> String {
        var result: String? = nil
        if !directTravelSegmentBuilder?.originAirport {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_ORIGIN_ERROR")
        }
        else if !directTravelSegmentBuilder?.destinationAirport {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_DESTINATION_ERROR")
        }
        else if directTravelSegmentBuilder?.originAirport?.isEqual(directTravelSegmentBuilder?.destinationAirport) {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_SAME_CITY_ERROR")
        }
        else if !directTravelSegmentBuilder?.departureDate {
            result = NSLS("JR_SEARCH_FORM_AIRPORT_EMPTY_DEPARTURE_DATE")
        }

        return result!
    }

    func buildTravelSegments() {
        var travelSegments: NSMutableOrderedSet<JRSDKTravelSegment>? = NSMutableOrderedSet()
        travelSegments?.append(directTravelSegmentBuilder?.build())
        if isShouldSetReturnDate {
            let returnTravelSegmentBuilder = JRSDKTravelSegmentBuilder()
            returnTravelSegmentBuilder.originAirport = directTravelSegmentBuilder?.destinationAirport
            returnTravelSegmentBuilder.destinationAirport = directTravelSegmentBuilder?.originAirport
            returnTravelSegmentBuilder.departureDate = returnDate
            travelSegments?.append(returnTravelSegmentBuilder.build())
        }
        searchInfoBuilder.travelSegments = travelSegments?
    }

    func buildSearchInfo() -> JRSDKSearchInfo {
        var result: JRSDKSearchInfo? = nil
        let error: String = validateTravelSegmentBuilder()
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