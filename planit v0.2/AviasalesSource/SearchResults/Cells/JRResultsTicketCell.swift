//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRResultsTicketCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import AviasalesSDK
import UIKit

private let kPriceCellReusableId: String = "JRResultsTicketPriceCell"
private let kFlightSegmentCellReusableID: String = "JRResultsFlightSegmentCell"
private let kBottomPadding: CGFloat = 12

class JRResultsTicketCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    private var _ticket: JRSDKTicket?
    var ticket: JRSDKTicket? {
        get {
            return _ticket
        }
        set(ticket) {
            _ticket = ticket
            tableView.reloadData()
        }
    }
    var flightSegmentsLayoutParameters: JRSearchResultsFlightSegmentCellLayoutParameters?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    class func nibFileName() -> String {
        return "JRResultsTicketCell"
    }

    class func height(with ticket: JRSDKTicket) -> CGFloat {
        return JRResultsTicketPriceCell.height + JRResultsFlightSegmentCell.height * ticket.flightSegments.count + kBottomPadding
    }

// MARK: - Static methods

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier as? String ?? "")
        
        // Initialization code
        selectionStyle = []
        registerTableReusableCells()
    
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = []
        registerTableReusableCells()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBackground()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackground()
    }

// MARK: - Setters

    override func setBackgroundColor(_ backgroundColor: UIColor) {
        super.backgroundColor = backgroundColor as? CGColor ?? CGColor()
        tableView.backgroundColor = backgroundColor
        containerView.backgroundColor = backgroundColor
        for cell: UITableViewCell in tableView.visibleCells {
            cell.backgroundColor = backgroundColor
        }
    }

// MARK: - <UITableViewDataSource>
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticket.flightSegments.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let cell: JRResultsTicketPriceCell? = tableView.dequeueReusableCell(withIdentifier: kPriceCellReusableId)
                cell?.airline = ticket.mainAirline
                let minProposal: JRSDKProposal? = JRSDKModelUtils.ticketMinimalPriceProposal(ticket)
                cell?.price = minProposal?.price
                return cell!
            default:
                let cell: JRResultsFlightSegmentCell? = tableView.dequeueReusableCell(withIdentifier: kFlightSegmentCellReusableID)
                cell?.layoutParameters = flightSegmentsLayoutParameters
                cell?.flightSegment = ticket.flightSegments[indexPath.row - 1]
                return cell!
        }

    }

// MARK: - <UITableViewDelegate>
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0:
                return JRResultsTicketPriceCell.height
            default:
                return JRResultsFlightSegmentCell.height
        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = backgroundColor
    }

// MARK: - Private
    func registerTableReusableCells() {
        tableView.register(UINib(nibName: JRResultsTicketPriceCell.nibFileName(), bundle: nil), forCellReuseIdentifier: kPriceCellReusableId)
        tableView.register(UINib(nibName: JRResultsFlightSegmentCell.nibFileName(), bundle: nil), forCellReuseIdentifier: kFlightSegmentCellReusableID)
    }

    func updateBackground() {
        if isSelected || isHighlighted {
            backgroundColor = JRColorScheme.itemsSelectedBackgroundColor()
        }
        else {
            backgroundColor = JRColorScheme.itemsBackgroundColor()
        }
    }
}