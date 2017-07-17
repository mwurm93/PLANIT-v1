//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import MessageUI
import sys

let kReportFileName: String = "Technical Report.gz"

class HLEmailSender: NSObject, MFMailComposeViewControllerDelegate {
    var mailer: HLMailComposeVC?
    weak var delegate: MFMailComposeViewControllerDelegate?

    class func canSendEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    class func showUnavailableAlert(in controller: UIViewController) {
        HLAlertsFabric.showMailSenderUnavailableAlert(in: controller)
    }

    func sendFeedbackEmail(to email: String) {
        var error: Error? = nil
        let toRecipients: [Any] = [email]
        var techReport: Data? = getTechInfo().data(using: String.Encoding.utf16, allowLossyConversion: false)
        techReport = try? BZipCompression.compressedData(with: techReport, blockSize: BZipDefaultBlockSize, workFactor: BZipDefaultWorkFactor)
        mailer?.setSubject(NSLS("HL_LOC_MAIL_FEEDBACK_SUBJECT"))
        mailer?.setToRecipients(toRecipients)
        mailer?.addAttachmentData(techReport, mimeType: "application/zip", fileName: kReportFileName)
    }

    override init() {
        super.init()
        
        createMailer()
    
    }

    func createMailer() {
        if HLEmailSender.canSendEmail() {
            mailer = HLMailComposeVC()
            mailer?.mailComposeDelegate = self
        }
    }

    func getTechInfo() -> String {

        var systemInfo: utsname
        uname(systemInfo)
        let device = String(cString: systemInfo.machine, encoding: String.Encoding.utf8)
        var techInfo = String()
        techInfo += "\n\n\n"
        techInfo += NSLS("HL_LOC_MAIL_FEEDBACK_BODY")
        techInfo += "\nDevice: \(device)"
        techInfo += "\niOS version: \(UIDevice.currentDevice.systemVersion)"
        techInfo += "\nApplication version: \(Bundle.main.infoDictionary["CFBundleVersion"])"
        techInfo += "\nApplication name: \(Bundle.main.infoDictionary["CFBundleName"])"
        techInfo += "\nMobile Token: \(HDKTokenManager.mobileToken())"
        return techInfo
    }

// MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        weak var weakSelf: HLEmailSender? = self
        mailer?.dismiss(animated: true, completion: {() -> Void in
            if weakSelf?.self.delegate?.responds(to: Selector("mailComposeController:didFinishWithResult:error:")) {
                try? weakSelf?.self.delegate?.mailComposeController(controller, didFinishWith: result)
            }
            weakSelf?.createMailer()
        })
    }
}