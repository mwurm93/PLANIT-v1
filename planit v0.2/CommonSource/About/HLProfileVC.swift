//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
private var kDefaultHeaderHeight: CGFloat = 20.0

class HLProfileVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, ProfileTableItemDelegate {
    weak var cellFactory: ProfileCellFactoryProtocol?
    @IBOutlet weak var tableView: UITableView!
    var profileSections: ProfileSections?
    var emailSender: HLEmailSender?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLS("LOC_SETTINGS_TITLE")
        cellFactory = ProfileCellsFactory()
        let tableFooterView: HLAboutFooterView? = LOAD_VIEW_FROM_NIB_NAMED("HLAboutFooterView")
        tableFooterView?.autoresizingMask = []
        tableView.tableFooterView = tableFooterView
        tableView.hl_registerNib(withName: HLProfileSelectableCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLProfileCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLProfileCurrencyCell.hl_reuseIdentifier())
        if iPad() {
            scrollViewTouchableArea = tableView
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        centerTableViewVertically()
    }

    func reloadData() {
        profileSections = cellFactory?.createSections(self)
        tableView.reloadData()
    }

    func centerTableViewVertically() {
        if iPad() {
            let footerEmptySpace: CGFloat = 20.0
            let contentInset: UIEdgeInsets = tableView.contentInset
            let inset: CGFloat = (view.frame.size.height - tableView.contentSize.height - (bottomLayoutGuide.characters.count ?? 0) + footerEmptySpace) / 2.0
            contentInset.top = inset
            tableView.contentInset = contentInset
        }
    }

    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
        centerTableViewVertically()
    }

// MARK: - UITableViewDataSource, UITableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSections?.sections?.count!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionObject: AboutTableSection? = profileSections?.sections[section]
        return sectionObject?.items()?.count!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionObject: AboutTableSection? = profileSections?.sections[indexPath.section]
        let item: HLProfileTableItem? = sectionObject?.items()[indexPath.row]
        return item?.height!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? kDefaultHeaderHeight : ZERO_HEADER_HEIGHT
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var result: CGFloat
        if section < profileSections?.sections?.count - 1 {
            result = kDefaultHeaderHeight
            let sectionObject: AboutTableSection? = profileSections?.sections[section]
            let footerTitle: String? = sectionObject?.descriptionTitle
            if footerTitle != nil {
                let width: CGFloat = tableView.frame.size.width
                result += HLSectionFooterView.calculateHeight(footerTitle, width: width)
            }
        }
        else {
            result = ZERO_HEADER_HEIGHT
        }
        return result
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var result: UIView? = nil
        let sectionObject: AboutTableSection? = profileSections?.sections[section]
        let footerTitle: String? = sectionObject?.descriptionTitle
        if footerTitle != nil {
            let footerView: HLSectionFooterView? = (loadViewFromNibNamed("HLSectionFooterView") as? HLSectionFooterView)
            footerView?.footerLabel?.text = footerTitle
            let width: CGFloat = tableView.frame.size.width
            let height: CGFloat = HLSectionFooterView.calculateHeight(footerTitle, width: width)
            footerView?.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            result = footerView
        }
        else {
            result = UIView()
            result?.backgroundColor = UIColor.clear
        }
        return result!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionObject: AboutTableSection? = profileSections?.sections[indexPath.section]
        let item: HLProfileTableItem? = sectionObject?.items()[indexPath.row]
        let cell: HLProfileCellProtocol? = tableView.dequeueReusableCell(withIdentifier: item?.cellIdentifier)
        cell?.setup(with: item)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionObject: AboutTableSection? = profileSections?.sections[indexPath.section]
        let item: HLProfileTableItem? = sectionObject?.items()[indexPath.row]
        if item?.action != nil {
            item?.action()
        }
        item?.isActive = !item?.isActive
        let cell: HLProfileCellProtocol? = tableView.cellForRow(at: indexPath)
        cell?.setup(with: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: - ProfileTableItemDelegate
    func canSendEmail() -> Bool {
        return kContactUsEmail.containsString("@")
    }

    func sendEmail() {
        if HLEmailSender.canSendEmail() {
            emailSender = HLEmailSender()
            emailSender?.sendFeedbackEmail(to: kContactUsEmail)
            present(emailSender?.mailer, animated: true) { _ in }
        }
        else {
            HLEmailSender.showUnavailableAlert(inController: self)
        }
    }

    func showDevSettings() {
        let settingsVC = ASTDevSettingsVC(nibName: "ASTDevSettingsVC", bundle: nil)
        navigationController?.pushViewController(settingsVC as? UIViewController ?? UIViewController(), animated: true)
    }

    func openCurrencySelector() {
        let currencyVC = HLCurrencyVC(nibName: "ASTGroupedSearchVC", bundle: nil)
        navigationController?.pushViewController(currencyVC as? UIViewController ?? UIViewController(), animated: true)
    }

    func rateApp() {
        let url = URL(string: kAppStoreRateLink)
        UIApplication.shared.openURL(url)
    }

    func canRateApp() -> Bool {
        return (kAppStoreRateLink.characters.count ?? 0) > 0
    }
}