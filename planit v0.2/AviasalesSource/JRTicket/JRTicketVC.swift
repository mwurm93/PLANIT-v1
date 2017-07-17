//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRTicketVC.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let kFlightCellHeight: CGFloat = 180.0
private let kTransforCellHeight: CGFloat = 56.0
private let kFlightsSegmentHeaderHeight: CGFloat = 94.0
private let kOffsetLimit: CGFloat = 50.0
private let kInfoPanelViewMaxHeightConstraint: CGFloat = 150.0
private let kSearchResultsTTL: TimeInterval = 15 * 60

class JRTicketVC: JRViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

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
    var searchInfo: JRSDKSearchInfo?
    var searchId: String = ""
    var infoPanelView: JRInfoPanelView?
    var isTableViewInsetsDidSet: Bool = false
    @IBOutlet weak var infoPanelContainerView: UIView!
    @IBOutlet weak var infoPanelViewHeightConstraint: NSLayoutConstraint!

    init(searchInfo: JRSDKSearchInfo, searchID: String) {
        super.init()
        
        self.searchInfo = searchInfo
        searchId = searchID
    
    }

    func setTicket(_ ticket: JRSDKTicket) {
        _ticket = ticket
        updateContent()
    }

    deinit {
        if iPhone() {
            tableView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        if iPhone() {
            tableView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld, context: nil)
        }
        updateContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isTableViewInsetsDidSet {
            isTableViewInsetsDidSet = true
            setupTableViewInsets()
        }
    }

// MARK: - Properties

// MARK: - Setup
    func setupViewController() {
        setupTableView()
        setupNavigationItems()
        setupInfoPanelView()
    }

    func setupTableView() {
        let flightCellNib = UINib(nibName: "JRFlightCell", bundle: AVIASALES_BUNDLE)
        let transferCellNib = UINib(nibName: "JRTransferCell", bundle: AVIASALES_BUNDLE)
        let flightsSegmentHeaderNib = UINib(nibName: "JRFlightsSegmentHeaderView", bundle: AVIASALES_BUNDLE)
        tableView.register(flightCellNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRFlightCell")
        tableView.register(transferCellNib as? UINib ?? UINib(), forCellReuseIdentifier: "JRTransferCell")
        tableView.register(flightsSegmentHeaderNib as? UINib ?? UINib(), forHeaderFooterViewReuseIdentifier: "JRFlightsSegmentHeaderView")
        tableView.separatorStyle = []
    }

    func setupTableViewInsets() {
        let tableViewInsets: UIEdgeInsets = tableView.contentInset
        let insets: UIEdgeInsets = UIEdgeInsetsMake(tableViewInsets.top(), tableViewInsets.left, (bottomLayoutGuide.characters.count ?? 0), tableViewInsets.right)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

    func setupNavigationItems() {
        title = JRSearchInfoUtils.formattedIatasAndDatesExcludeYearComponent(for: searchInfo)
    }

    func setupInfoPanelView() {
        infoPanelView = LOAD_VIEW_FROM_NIB_NAMED("JRInfoPanelView")
        infoPanelView?.translatesAutoresizingMaskIntoConstraints = false
        infoPanelContainerView.addSubview(infoPanelView!)
        infoPanelContainerView.addConstraints(JRConstraintsMakeScaleToFill(infoPanelView, infoPanelContainerView))
    }

// MARK: - Update
    func updateContent() {
        updateInfoPanelView()
        tableView.reloadData()
    }

    func updateInfoPanelView() {
        infoPanelView?.ticket = ticket
        weak var weakSelf: JRTicketVC? = self
        infoPanelView?.buyHandler = {() -> Void in
            weakSelf?.buyTicket(withProposal: weakSelf?.self.ticket?.proposals?.first)
        }
        infoPanelView?.showOtherAgencyHandler = {() -> Void in
            weakSelf?.showOtherAgencies()
        }
    }

// MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticket.flightSegments.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let flightsCount: Int = ticket.flightSegments[section].flights.count
        return (flightsCount > 0) ? 2 * flightsCount - 1 : flightsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: JRTicketCellProtocol?
        var flightIndex: Int = indexPath.row
        if indexPath.row % 2 == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "JRFlightCell", for: indexPath)
            flightIndex -= flightIndex / 2
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "JRTransferCell", for: indexPath)
            flightIndex = (flightIndex + 1) / 2
        }
        let flight: JRSDKFlight? = ticket.flightSegments[indexPath.section].flights[flightIndex]
        cell?.apply(flight)
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: JRFlightsSegmentHeaderView? = (tableView.dequeueReusableHeaderFooterView(withIdentifier: "JRFlightsSegmentHeaderView") as? JRFlightsSegmentHeaderView)
        header?.flightSegment = ticket.flightSegments[section]
        return header!
    }

// MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return kFlightCellHeight
        }
        else {
            return kTransforCellHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFlightsSegmentHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

// MARK: - Private
    override func observeValue(forKeyPath keyPath: String, of object: Any, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
        if (object == tableView) && (keyPath == "contentOffset") {
            let newOffset = change.value(forKey: NSKeyValueChangeNewKey) as? CGPoint ?? CGPoint.zero.cgPointValue
            let oldOffset = change.value(forKey: NSKeyValueChangeOldKey) as? CGPoint ?? CGPoint.zero.cgPointValue
            let contentHeightLimit: CGFloat = view.bounds.size.height - kOffsetLimit
            if (newOffset.y != oldOffset.y) && (tableView.contentSize.height > contentHeightLimit) {
                updateInfoPanelView(withOffset: newOffset.y)
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath as? String ?? "", of: object, change: change as? [String : Any] ?? [String : Any](), context: context as? UnsafeMutableRawPointer ?? UnsafeMutableRawPointer())
        }
    }

    func showOtherAgencies() {
        let alertController = UIAlertController(title: AVIASALES_("JR_TICKET_BUY_IN_THE_AGENCY_BUTTON"), message: nil, preferredStyle: .actionSheet)
        weak var weakSelf: JRTicketVC? = self
        for proposal: JRSDKProposal in ticket.proposals {
            let title: String = "\(proposal.gate.label) — \(JRPriceUtils.formattedPrice(inUserCurrency: proposal.price))"
            let buyAction = UIAlertAction(title: title as? String ?? "", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    weakSelf?.buyTicket(with: proposal)
                })
            alertController.addAction(buyAction)
        }
        let cancelAction = UIAlertAction(title: AVIASALES_("JR_CANCEL_TITLE"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if iPad() {
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController.sourceView = infoPanelView?.showOtherAgenciesButton
            alertController.popoverPresentationController.sourceRect = infoPanelView?.showOtherAgenciesButton?.bounds
        }
        present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    func updateInfoPanelView(withOffset offset: CGFloat) {
        let delta: CGFloat = min(kOffsetLimit, max(offset, 0.0))
        let percent: CGFloat = delta / kOffsetLimit
        infoPanelViewHeightConstraint.constant = kInfoPanelViewMaxHeightConstraint - delta
        infoPanelContainerView.layer.masksToBounds = !(percent > 0.0)
        infoPanelContainerView.setNeedsLayout()
        infoPanelContainerView.layoutIfNeeded()
        percent > 0.25 ? infoPanelView?.collapse() : infoPanelView?.expand()
    }

    func isTicketExpired() -> Bool {
        return Date().timeIntervalSince(ticket.searchResultInfo.receivingDate) > kSearchResultsTTL
    }

    func showTicketExpiredAlert() {
        let alertController = UIAlertController(title: NSLS("JR_TICKET_EXPIRED"), message: nil, preferredStyle: .alert)
        weak var weakSelf: JRTicketVC? = self
        alertController.addAction(UIAlertAction(title: NSLS("JR_NEW_SEARCH_TITLE"), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            weakSelf?.navigationController?.popToRootViewController(animated: true)
        }))
        alertController.addAction(UIAlertAction(title: NSLS("JR_CANCEL_TITLE"), style: .cancel, handler: nil))
        present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    func showGateBrowser(with proposal: JRSDKProposal) {
        let gateBrowserViewController = ASTGateBrowserViewController(ticketProposal: proposal, searchID: searchId)
        let naviagtionController = JRNavigationController(rootViewController: gateBrowserViewController)
        present(naviagtionController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    func buyTicket(with proposal: JRSDKProposal) {
        if isTicketExpired() {
            showTicketExpiredAlert()
        }
        else {
            showGateBrowser(with: proposal)
        }
    }
}