//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLAboutFooterView: UIView {
    @IBOutlet weak var versionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        let info: [AnyHashable: Any]? = Bundle.main.infoDictionary
        let version: String = info?["CFBundleShortVersionString"] as? String ?? ""
        versionLabel.text = "\(NSLS("HL_LOC_ABOUT_VERSION_TITLE")) \(version)"
    }
}