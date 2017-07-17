//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLIpadSearchVC: HLSearchVC, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, KidsPickerDelegate {
    @IBOutlet weak var shadowView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.backgroundColor = JRColorScheme.searchFormBackgroundColor()
        shadowView.applyShadowLayer()
    }

// MARK: - Override
    func presentCityPicker(_ cityPickerVC: HLCityPickerVC, animated: Bool) {
        customPresent(cityPickerVC, animated: animated)
    }

    func kidsPickerPopoverSize() -> CGSize {
        return CGSize(width: 320.0, height: 320.0)
    }

// MARK: - HLSearchFormDelegate
    func showKidsPicker() {
        let kidsPickerVC = HLIpadKidsPickerVC(nibName: "HLIpadKidsPickerVC", bundle: nil)
        kidsPickerVC.searchInfo = searchInfo
        kidsPickerVC.delegate = self
        presentPopover(kidsPickerVC, above: searchForm.kidsButton, distance: 15.0, contentSize: kidsPickerPopoverSize(), backgroundColor: UIColor.gray)
    }

    func showDatePicker() {
        let datePickerVC = HLDatePickerVC(nibName: "HLDatePickerVC", bundle: nil)
        datePickerVC.searchInfo = searchInfo
        customPresent(datePickerVC, animated: true)
    }

// MARK: - KidsPickerDelegate Methods
    func kidsSelected() {
        updateControls()
    }
}