//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRInfoPanelView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let kBuyButtonMaxTopConstraint: CGFloat = 75.0
private let kBuyButtonMinTopConstraint: CGFloat = 25.0
private let kShowOtherAgenciesButtonMaxTopConstraint: CGFloat = 15.0
private let kShowOtherAgenciesButtonMinTopConstraint: CGFloat = -25.0
private let kBuyButtonMinRightConstraint: CGFloat = 30.0
private let kAgencyInfoLabelMinCenterConstraint: CGFloat = 0.0
private let kAgencyInfoLabelMaxCenterConstraint: CGFloat = 15.0

class JRInfoPanelView: UIView {
    private var _ticket: JRSDKTicket?
    var ticket: JRSDKTicket? {
        get {
            return _ticket
        }
        set(ticket) {
            _ticket = ticket
            updateContent()
        }
    }
    @IBOutlet weak var showOtherAgenciesButton: UIButton!
    var buyHandler: ((_: Void) -> Void)? = nil
    var showOtherAgencyHandler: ((_: Void) -> Void)? = nil

    @IBOutlet weak var buyButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var showOtherAgenciesButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var agencyInfoLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var agencyInfoLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var agencyInfoLabelLeftContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var agencyInfoLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!

    func expand() {
        layer.removeAllAnimations()
        buyButtonTopConstraint.constant = kBuyButtonMaxTopConstraint
        showOtherAgenciesButtonTopConstraint.constant = kShowOtherAgenciesButtonMaxTopConstraint
        buyButtonLeftConstraint.constant = kBuyButtonMinRightConstraint
        if showOtherAgenciesButton.isHidden {
            moveUpAgencyInfoLabel()
        }
        showOtherAgenciesButton.alpha = 1.0
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }) { _ in }
    }

    func collapse() {
        layer.removeAllAnimations()
        buyButtonTopConstraint.constant = kBuyButtonMinTopConstraint
        showOtherAgenciesButtonTopConstraint.constant = kShowOtherAgenciesButtonMinTopConstraint
        buyButtonLeftConstraint.constant = kBuyButtonMinRightConstraint + 0.5 * bounds.size.width
        if showOtherAgenciesButton.isHidden {
            moveDownAgencyInfoLabel()
        }
        showOtherAgenciesButton.alpha = 0.0
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }) { _ in }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showOtherAgenciesButton.setTitle(AVIASALES_("JR_TICKET_OTHER_BUTTON"), for: .normal)
        showOtherAgenciesButton.layer.borderWidth = 1.0
        showOtherAgenciesButton.layer.borderColor = JRColorScheme.navigationBarItemColor().cgColor
        showOtherAgenciesButton.layer.cornerRadius = 4.0
        updateContent()
    }

// MARK: Public methods

// MARK: Private methods
    func moveUpAgencyInfoLabel() {
        agencyInfoLabelCenterConstraint.constant = kAgencyInfoLabelMinCenterConstraint
        agencyInfoLabelLeftConstraint.priority = .defaultHigh
        agencyInfoLabelLeftContainerConstraint.priority = .defaultLow
    }

    func moveDownAgencyInfoLabel() {
        agencyInfoLabelCenterConstraint.constant = kAgencyInfoLabelMaxCenterConstraint
        agencyInfoLabelLeftConstraint.priority = .defaultLow
        agencyInfoLabelLeftContainerConstraint.priority = .defaultHigh
    }

    func updateContent() {
        let gate: JRSDKGate? = ticket.proposals.first?.gate
        if gate != nil {
            agencyInfoLabel.text = "\(AVIASALES_("JR_SEARCH_RESULTS_TICKET_IN_THE")) \(gate?.label)"
        }
        else {
            agencyInfoLabel.text = ""
        }
        priceLabel.text = JRTicketUtils.formattedTicketMinPrice(inUserCurrency: ticket)
        let proposalsCount: Int = ticket.proposals.count
        let showOtherButton: Bool = proposalsCount > 1
        showOtherAgenciesButton.isHidden = !showOtherButton
        if showOtherButton {
            moveDownAgencyInfoLabel()
        }
        else {
            moveUpAgencyInfoLabel()
        }
        buyButton.setTitle(AVIASALES_("JR_TICKET_BUY_BUTTON").uppercased(), for: .normal)
    }

// MARK: IBAction methods
    @IBAction func buyBest(_ sender: Any) {
        buyHandler()
    }

    @IBAction func showOtherAgencies(_ sender: Any) {
        showOtherAgencyHandler()
    }
}