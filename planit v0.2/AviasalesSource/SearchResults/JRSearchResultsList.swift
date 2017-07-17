//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSearchResultsList.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

protocol JRSearchResultsListDelegate: NSObjectProtocol {
    func tickets() -> [JRSDKTicket]

    func didSelectTicket(at index: Int)
}

class JRSearchResultsList: NSObject, JRTableManager {
    weak var delegate: JRSearchResultsListDelegate?
    private(set) var ticketCellNibName: String = ""
    var flightSegmentLayoutParameters: JRSearchResultsFlightSegmentCellLayoutParameters?

    init(cellNibName: String) {
        super.init()

        ticketCellNibName = cellNibName
    
    }

// MARK: - <UITableViewDataSource>
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.tickets()?.count!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "JRResultsTicketCell"
        var cell: JRResultsTicketCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = AVIASALES_BUNDLE.loadNibNamed(ticketCellNibName, owner: self, options: nil)?[0] as? JRResultsTicketCell
        }
        cell?.flightSegmentsLayoutParameters = flightSegmentLayoutParameters
        cell?.ticket = ticket(at: indexPath)
        return cell!
    }

// MARK: - <UITableViewDelegate>
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ticket: JRSDKTicket? = self.ticket(at: indexPath)
        return JRResultsTicketCell.height(with: ticket)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index: Int = indexPath.section
        delegate?.didSelectTicket(at: index)
    }

// MARK: - Private
    func ticket(at indexPath: IndexPath) -> JRSDKTicket {
        let index: Int = indexPath.section
        return delegate?.tickets()?[index]!
    }
}