//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

class HLSearchVC: HLCommonVC, HLSearchFormDelegate, HLCityPickerDelegate, HLSearchInfoChangeDelegate, HLCustomPointSelectionDelegate, TicketsSearchDelegate {
    weak var searchForm: HLSearchForm?
    private var _searchInfo: HLSearchInfo?
    var searchInfo: HLSearchInfo? {
        get {
            if !_searchInfo {
                _searchInfo = HDKDefaultsSaver.loadObject(with: HL_DEFAULTS_SEARCH_INFO_KEY) ?? HLSearchInfo.default()
            }
            return _searchInfo
        }
        set(searchInfo) {
            _searchInfo = searchInfo
            updateControls()
        }
    }

    @IBOutlet weak var searchFormContainerView: UIView!
    var hotelDetailsDecorator: HLHotelDetailsSearchDecorator?

    func updateControls() {
        searchForm?.searchInfo = searchInfo
        updateSearchFormControls()
    }

    func tryToStartSearch(with searchInfo: HLSearchInfo) {
        if self.searchInfo.readyToSearch() {
            performSearch(with: searchInfo)
        }
        else {
            HLAlertsFabric.showEmptySearchFormAlert(searchInfo, inController: self)
        }
    }

    func performSearch(with searchInfo: HLSearchInfo) {
        HDKDefaultsSaver.saveObject(searchInfo, for: HL_DEFAULTS_SEARCH_INFO_KEY)
        if searchInfo.hotel {
            let variant = HLResultVariant.createEmpty(searchInfo, hotel: searchInfo.hotel)
            hotelDetailsDecorator = HLHotelDetailsSearchDecorator(variant: variant, photoIndex: 0, photoIndexUpdater: nil, filter: nil)
            navigationController?.pushViewController(hotelDetailsDecorator?.detailsVC, animated: true)
        }
        else {
            let waitingVC = WaitingVC(nibName: "WaitingVC", bundle: nil)
            waitingVC.searchInfo = searchInfo
            navigationController?.pushViewController(waitingVC as? UIViewController ?? UIViewController(), animated: true)
        }
    }

    func presentCityPicker(_ cityPickerVC: HLCityPickerVC, animated: Bool) {
        navigationController?.pushViewController(cityPickerVC as? UIViewController ?? UIViewController(), animated: animated)
    }

    @IBAction func showCityOrMapPicker() {
        if searchInfo.locationPoint {
            showMapPicker()
        }
        else {
            showCityPicker()
        }
    }

    func showCityPicker(withText searchText: String, animated: Bool) {
        let pickerVC: HLCityPickerVC? = cityPicker()
        pickerVC?.searchInfo = searchInfo
        pickerVC?.delegate = self
        pickerVC?.initialSearchText = searchText
        presentCityPicker(pickerVC, animated: animated)
    }

    func setCityToSearchForm(_ city: HDKCity) {
        searchInfo.city = city
        updateControls()
    }

    override init() {
        super.init()
        
        InteractionManager.shared.hotelsSearchForm = self
    
    }

// MARK: - Properties

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchInfo.updateExpiredDates()
        title = NSLS("LOC_SEARCH_FORM_TITLE")
        registerForSearchInfoChangesNotifications()
        searchForm = Bundle.main.loadNibNamed("HLSearchForm", owner: nil, options: nil)?[0] as? HLSearchForm
        searchFormContainerView.addSubview(searchForm!)
        searchForm?.delegate = self
        searchForm?.searchInfo = searchInfo
        searchForm?.autoPinEdgesToSuperviewEdges()
        view.backgroundColor = JRColorScheme.searchFormBackgroundColor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hotelDetailsDecorator = nil
    }

    func updateSearchFormControls() {
        searchForm?.updateControls()
    }

    func cityPickerVC() -> HLCityPickerVC {
        return HLCityPickerVC(nibName: "ASTGroupedSearchVC", bundle: nil)
    }

// MARK: - Actions
    func selectCurrentLocation() {
        HLLocationManager.sharedManager().requestUserLocation(withLocationDestination: kForceCurrentLocationToSearchForm)
        let locationPoint: HDKSearchLocationPoint? = HLSearchUserLocationPoint.forCurrentLocation()
        if locationPoint != nil {
            searchInfo.locationPoint = locationPoint
            updateSearchFormControls()
        }
        HLNearbyCitiesDetector.shared.detectCurrentCity(with: searchInfo)
    }

    func showCityPicker() {
        showCityPicker(withText: nil, animated: true)
    }

    func showMapPicker() {
        let customMapPointSelectionVC = HLCustomPointSelectionVC(nibName: "HLCustomPointSelectionVC", bundle: nil)
        customMapPointSelectionVC.delegate = self
        customMapPointSelectionVC.initialSearchInfoLocation = searchInfo.searchLocation
        customMapPointSelectionVC.modalPresentationStyle = .formSheet
        present(customMapPointSelectionVC as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

// MARK: - HLCityPickerDelegate
    func cityPicker(_ picker: HLCityPickerVC, didSelect city: HDKCity) {
        updateSearch(city)
        searchInfo.hotel = nil
        updateControls()
    }

    func cityPicker(_ picker: HLCityPickerVC, didSelect hotel: HDKHotel) {
        if hotel.city {
            updateSearchCity(hotel.city)
        }
        searchInfo.hotel = hotel
    }

    func updateSearch(_ newCity: HDKCity) {
        searchInfo.city = newCity
    }

    func cityPicker(_ picker: HLCityPickerVC, didSelect airport: HDKAirport) {
        searchInfo.airport = airport
        searchInfo.locationPoint = HLSearchAirportLocationPoint(airport: airport)
    }

    func cityPicker(_ picker: HLCityPickerVC, didSelect locationPoint: HDKSearchLocationPoint) {
        update(locationPoint)
    }

    func update(_ locationPoint: HDKSearchLocationPoint) {
        searchInfo.locationPoint = locationPoint
    }

// MARK: - HLCustomPointSelectionDelegate methods
    func didSelectCustomSearchLocationPoint(_ searchLocationPoint: HDKSearchLocationPoint) {
        navigationController?.popViewController(animated: true)
        searchInfo.locationPoint = searchLocationPoint
    }

// MARK: - HLSearchInfoChangeDelegate methods
    func searchInfoChangedNotification(_ notification: Notification) {
        if searchInfo == notification.object {
            hl_dispatch_main_async_safe({() -> Void in
                self.updateControls()
            })
        }
    }

    func cityInfoDidLoad(_ notification: Notification) {
        hl_dispatch_main_async_safe({() -> Void in
            let notificationCity: HDKCity? = (notification.object as? [Any])?.first
            if notificationCity?.cityId?.isEqual(searchInfo.city.cityId) {
                searchInfo.city = notificationCity
            }
            self.updateControls()
        })
    }

// MARK: - HLNearbyCitiesDetectionDelegate methods
    func nearbyCitiesDetected(_ notification: Notification) {
        let nearbyCities: [Any]? = (notification.object as? [Any])
        let city: HDKCity? = nearbyCities?.first
        if (city? is HDKCity) {
            let currentLocationDestination: String? = notification.userInfo[kCurrentLocationDestinationKey]
            if currentLocationDestination?.isEqual(kForceCurrentLocationToSearchForm) || currentLocationDestination?.isEqual(kStartCurrentLocationSearch) {
                let locationPoint: HDKSearchLocationPoint? = HLSearchUserLocationPoint.forCurrentLocation()
                if locationPoint != nil {
                    searchInfo.locationPoint = locationPoint
                }
            }
            if currentLocationDestination?.isEqual(kStartCurrentLocationSearch) {
                tryToStartSearch(with: searchInfo)
                HLNearbyCitiesDetector.shared.dropCurrentLocationSearchDestination()
            }
            updateControls()
        }
    }

// MARK: - HLSearchFormDelegate
    func onSearch(_ searchForm: HLSearchForm) {
        searchInfo.currency = InteractionManager.shared.currency
        tryToStartSearch(with: searchInfo)
    }

    func showKidsPicker() {
        let kidsPicker = HLKidsPickerVC(nibName: "HLKidsPickerVC", bundle: nil)
        kidsPicker.searchInfo = searchInfo
        navigationController?.pushViewController(kidsPicker as? UIViewController ?? UIViewController(), animated: true)
    }

    func showDatePicker() {
        let datePickerVC = HLDatePickerVC(nibName: "HLDatePickerVC", bundle: nil)
        datePickerVC.searchInfo = searchInfo
        navigationController?.pushViewController(datePickerVC as? UIViewController ?? UIViewController(), animated: true)
    }

// MARK: - TicketsSearchDelegate
    func updateSearchInfo(with city: HDKCity, adults: Int, checkIn: Date, checkOut: Date) {
        searchInfo.hotel = nil
        searchInfo.city = city
        searchInfo.adultsCount = adults
        searchInfo.checkInDate = checkIn
        searchInfo.checkOutDate = checkOut
        updateControls()
        navigationController?.popToRootViewController(animated: false)
        tabBarController?.selectedViewController = navigationController
    }
}