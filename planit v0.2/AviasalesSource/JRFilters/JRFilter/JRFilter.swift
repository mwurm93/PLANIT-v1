//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

let kJRFilterBoundsDidChangeNotificationName = "kJRFilterBoundsDidChangeNotificationName"
let kJRFilterBoundsDidResetNotificationName = "kJRFilterBoundsDidResetNotificationName"
let kJRFilterMinPriceDidUpdateNotificationName = "kJRFilterMinPriceDidUpdateNotificationName"

protocol JRFilterDelegate: NSObjectProtocol {
    func filterDidUpdateFilteredObjects()
}

class JRFilter: NSObject, JRFilterTaskDelegate {
    private(set) var ticketBounds: JRFilterTicketBounds?
    private(set) var travelSegmentsBounds = [JRFilterTravelSegmentBounds]()
    private(set) var searchResultsTickets: NSOrderedSet<JRSDKTicket>?
    private(set) var filteredTickets: NSOrderedSet<JRSDKTicket>?
    var minFilteredPrice: JRSDKPrice? {
        return filteredTickets?.first?.proposals?.first?.price!
    }
    private(set) var searchInfo: JRSDKSearchInfo?
    private(set) var filteringTask: JRFilterTask?
    private(set) var isAllBoundsReseted: Bool = false
    weak var delegate: JRFilterDelegate?

    var lastTaskStartDate: Date?

    init(tickets: NSOrderedSet<JRSDKTicket>, searchInfo: JRSDKSearchInfo) {
        super.init()
        
        self.searchInfo = searchInfo
        searchResultsTickets = tickets
        filteredTickets = searchResultsTickets
        lastTaskStartDate = Date()
        travelSegmentsBounds = [Any]()
        let boundsBuilder = JRFilterBoundsBuilder(searchResults: searchResultsTickets, for: self.searchInfo)
        ticketBounds = boundsBuilder.ticketBounds
        travelSegmentsBounds = boundsBuilder.travelSegmentsBounds
        NotificationCenter.default.addObserver(self, selector: #selector(self.filterBoundsDidChange), name: kJRFilterBoundsDidChangeNotificationName, object: nil)
    
    }

    func resetAllBounds() {
        var boundsToReset: [Any] = travelSegmentsBounds
        boundsToReset.append(ticketBounds)
        resetFilterBounds(boundsToReset)
    }

    func resetFilterBounds(for travelSegment: JRSDKTravelSegment) {
        let travelSegmentBounds: JRFilterTravelSegmentBounds? = self.travelSegmentBounds(for: travelSegment)
        travelSegmentBounds?.reset()
        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: kJRFilterBoundsDidResetNotificationName, object: nil)
        })
        startNewFilteringTask()
    }

    func travelSegmentBounds(for travelSegment: JRSDKTravelSegment) -> JRFilterTravelSegmentBounds {
        for travelSegmentBounds: JRFilterTravelSegmentBounds in travelSegmentsBounds {
            if travelSegmentBounds?.travelSegment?.isEqual(travelSegment) {
                return travelSegmentBounds!
            }
        }
        return nil
    }

    func isTravelSegmentBoundsReseted(for travelSegment: JRSDKTravelSegment) -> Bool {
        let travelSegmentBounds: JRFilterTravelSegmentBounds? = self.travelSegmentBounds(for: travelSegment)
        return travelSegmentBounds?.isReset!
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - Public methds
    func isAllBoundsReseted() -> Bool {
        if !ticketBounds?.isReset {
            return false
        }
        for bounds: JRFilterTravelSegmentBounds in travelSegmentsBounds {
            if !bounds.isReset {
                return false
            }
        }
        return true
    }

    func resetFilterBounds(_ boundsToReset: [Any]) {
//clang diagnostic push
//clang diagnostic ignored "-Wundeclared-selector"
        boundsToReset.makeObjectsPerformSelector(#selector(self.resetBounds))
//clang diagnostic pop
        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: kJRFilterBoundsDidResetNotificationName, object: nil)
        })
        startNewFilteringTask()
    }

// MARK: - Private methds
    func filterBoundsDidChange(_ notification: Notification) {
        if notification.object == ticketBounds || travelSegmentsBounds.contains(notification.object) {
            let timeIntervalSinceLastTaskStartDate: TimeInterval = Date().timeIntervalSince(lastTaskStartDate)
            if timeIntervalSinceLastTaskStartDate > kJRFilterLastTaskStartDelay {
                startNewFilteringTask()
            }
            else {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.startNewFilteringTask), object: nil)
                perform(#selector(self.startNewFilteringTask), with: nil, afterDelay: kJRFilterLastTaskStartDelay)
            }
        }
    }

    func startNewFilteringTask() {
        lastTaskStartDate = Date()
        filteringTask = nil
        filteringTask = JRFilterTask(for: searchResultsTickets, ticketBounds: ticketBounds, travelSegmentBounds: travelSegmentsBounds, taskDelegate: self)
        weak var weakTask: JRFilterTask?? = filteringTask
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            weakTask?.performFiltering()
        })
    }

// MARK: - JRFilterTaskDelegate methds
    func filterTaskDidFinish(withTickets filteredTickets: NSOrderedSet<JRSDKTicket>) {
        self.filteredTickets = filteredTickets
        weak var weakSelf: JRFilter? = self
        DispatchQueue.main.sync(execute: {() -> Void in
            NotificationCenter.default.post(name: kJRFilterMinPriceDidUpdateNotificationName, object: self)
            weakSelf?.self.delegate?.filterDidUpdateFilteredObjects()
        })
    }
}

let kJRFilterLastTaskStartDelay = 0.3