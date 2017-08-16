class HLHotelDetailsPriceCTACell: HLPriceTableViewCell {

    var bookHandler: (() -> Void)!
    var photoHandler: (() -> Void)!

    @IBOutlet weak var discountInfoView: DiscountInfoView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet var photoButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var spaceBetweenButtonsConstraint: NSLayoutConstraint!

    @IBAction fileprivate func bookButtonPressed(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spawnBookHotelAlert"), object: nil)
        
//        let hotelItemsAccessoryMethodsPerformer = HotelItemsAccessoryMethodsPerformer()
//        let hlPriceTableViewCell = self as HLPriceTableViewCell
//        
//        hotelItemsAccessoryMethodsPerformer.saveLastOpenHotelRoom(hotelRoom: hlPriceTableViewCell.room)
    }
    func continueBookHotel() {
        bookHandler()
    }

    
    @IBAction fileprivate func photoButtonPressed(_ sender: AnyObject) {
        photoHandler()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bookButton.setTitle(NSLS("HL_HOTEL_DETAIL_BOOK_BUTTON_TITLE"), for: .normal)
        bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        bookButton.backgroundColor = JRColorScheme.mainButtonBackgroundColor()

        photoButton.setTitle(NSLS("HL_HOTEL_DETAIL_PHOTOS_BUTTON_TITLE"), for: .normal)
        photoButton.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
        photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        photoButton.layer.borderWidth = 1
        photoButton.layer.borderColor = JRColorScheme.mainButtonBackgroundColor().cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(continueBookHotel), name: NSNotification.Name(rawValue: "continueBookHotel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideJRTicketBuyButton), name: NSNotification.Name(rawValue: "hideJRTicketBuyButton"), object: nil)
        
    }
    func hideJRTicketBuyButton() {
        bookButton.isHidden = true
    }
    func hidePhotosButton() {
        photoButtonWidthConstraint.isActive = false
        spaceBetweenButtonsConstraint.isActive = false
    }

    func showPhotosButton() {
        photoButtonWidthConstraint.isActive = true
        spaceBetweenButtonsConstraint.isActive = true
    }

    class func calculateCellHeight(_ tableWidth: CGFloat, room: HDKRoom, currency: HDKCurrency, duration: Int) -> CGFloat {
        let photosAndBookButtonsHeight: CGFloat = 40.0

        return super.calculateCellHeight(tableWidth, room: room, currency: currency) + photosAndBookButtonsHeight
    }
}
