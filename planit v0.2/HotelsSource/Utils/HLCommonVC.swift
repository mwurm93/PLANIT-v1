//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import ObjectiveC
import PureLayout
import UIKit

class HLCommonVC: UIViewController, UIPopoverPresentationControllerDelegate {
    var popoverDistanceToAnchorView: CGFloat = 0.0
    var isDidSetupInitialConstraints: Bool = false
    var isShouldSetCustomTopLayoutGuide: Bool = false
    var customTopLayoutGuideLength: CGFloat = 0.0

// MARK: - view lifecycle

    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func addSearchInfoView(_ searchInfo: HLSearchInfo) {
        let view = HLSearchInfoNavBarView()
        view.configure(for: searchInfo)
        view.setupConstraints()
        let limits = CGSize(width: 375.0, height: 35.0)
        let size: CGSize = view.systemLayoutSizeFitting(limits)
        view.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        navigationItem.titleView = view
    }

    func disableScroll(forInteractivePopGesture scrollView: UIScrollView) {
        let rec: UIGestureRecognizer? = navigationController.interactivePopGestureRecognizer
        if rec != nil {
            scrollView.panGestureRecognizer.require(toFail: rec!)
        }
    }

    func showToast(_ toast: HLToastView, animated: Bool) {
        toast.show(view, animated: animated)
    }

    func insetableView() -> UIView? {
        var result: UIView?
        if responds(to: #selector(self.tableView)) {
            result = performSelector(#selector(self.tableView))
        }
        else if responds(to: #selector(self.collectionView)) {
            result = performSelector(#selector(self.collectionView))
        }
        else if responds(to: #selector(self.mapView)) {
            result = performSelector(#selector(self.mapView))
        }

        return result!
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (iPad() ? .all : .portrait)
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return (iPad() ? super.preferredInterfaceOrientationForPresentation : .portrait)
    }

    deinit {
        unregisterNotificationResponse()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JRColorScheme.mainBackgroundColor()
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem
    }

// MARK: - Public

// MARK: - Navbar setup

// MARK: - Private
    func isRootViewController() -> Bool {
        if navigationController.viewControllers?.count == 0 {
            return true
        }
        if navigationController.viewControllers[0] == self {
            return true
        }
        return false
    }

    func popoverEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(20.0, 20.0, 0.0, 20.0)
    }

    func setCornerRadius(_ cornerRadius: CGFloat, recursiveFor view: UIView) {
        view.layer.cornerRadius = cornerRadius
        if view.superview {
            setCornerRadius(cornerRadius, recursiveFor: view.superview)
        }
    }

    func popoverSourceRectFrame(withAnchorView anchorView: UIView) -> CGRect {
        let deltaY: CGFloat = popoverDistanceToAnchorView
        let rect = CGRect(x: 0.0, y: deltaY, width: anchorView.frame.size.width, height: anchorView.frame.size.height)
        return rect
    }

// MARK: - UIPopoverPresentationControllerDelegate methods
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: CGRect, in view: UIView) {
        popoverPresentationController.sourceRect = popoverSourceRectFrame(withAnchorView: popoverPresentationController.sourceView)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return []
    }
}

extension HLCommonVC {
    func presentPopover(_ contentVC: UIViewController, above anchorView: UIView, distance: CGFloat, contentSize: CGSize, backgroundColor color: UIColor) {
        presentPopover(contentVC, from: anchorView, distance: CGFloat(distance), permittedArrowDirections: .down, contentSize: contentSize, backgroundColor: color)
    }

    func presentPopover(_ contentVC: UIViewController, under anchorView: UIView, distance: CGFloat, contentSize: CGSize, backgroundColor color: UIColor) {
        presentPopover(contentVC, from: anchorView, distance: CGFloat(distance), permittedArrowDirections: .up, contentSize: contentSize, backgroundColor: color)
    }

    func presentPopover(_ contentVC: UIViewController, above anchorView: UIView, distance: CGFloat, contentSize: CGSize, backgroundColor color: UIColor, cornerRadius: CGFloat) {
        presentPopover(contentVC, from: anchorView, distance: CGFloat(distance), permittedArrowDirections: .down, contentSize: contentSize, backgroundColor: color, cornerRadius: cornerRadius)
    }

    func presentPopover(_ contentVC: UIViewController, under anchorView: UIView, distance: CGFloat, contentSize: CGSize, backgroundColor color: UIColor, cornerRadius: CGFloat) {
        presentPopover(contentVC, from: anchorView, distance: CGFloat(distance), permittedArrowDirections: .up, contentSize: contentSize, backgroundColor: color, cornerRadius: cornerRadius)
    }

    func presentPopover(_ contentVC: UIViewController, under anchorView: UIView, contentSize: CGSize) {
        presentPopover(contentVC, under: anchorView, distance: -6, contentSize: contentSize, backgroundColor: JRColorScheme.lightBackgroundColor(), cornerRadius: 20.0)
    }

    func customPresent(_ vc: UIViewController, animated: Bool) {
        let navVC = JRNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismiss))
        present(navVC as? UIViewController ?? UIViewController(), animated: animated) { _ in }
    }

    func presentPopover(_ contentVC: UIViewController, from anchorView: UIView, distance: CGFloat, permittedArrowDirections: UIPopoverArrowDirection, contentSize: CGSize, backgroundColor color: UIColor) {
        presentPopover(contentVC, from: anchorView, distance: CGFloat(distance), permittedArrowDirections: permittedArrowDirections, contentSize: contentSize, backgroundColor: color, cornerRadius: 5.0)
    }

    func presentPopover(_ contentVC: UIViewController, from anchorView: UIView, distance: CGFloat, permittedArrowDirections: UIPopoverArrowDirection, contentSize: CGSize, backgroundColor color: UIColor, cornerRadius: CGFloat) {
        let insets: UIEdgeInsets = popoverEdgeInsets()
        let isUpDirection: Bool = permittedArrowDirections & .up
        popoverDistanceToAnchorView = isUpDirection ? distance : -distance
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = contentSize
        let presentationController: UIPopoverPresentationController? = contentVC.popoverPresentationController
        presentationController?.delegate = self
        presentationController?.popoverLayoutMargins = insets
        presentationController?.sourceRect = popoverSourceRectFrame(withAnchorView: anchorView)
        presentationController?.sourceView = anchorView
        presentationController?.permittedArrowDirections = permittedArrowDirections
        presentationController?.backgroundColor = color
        present(contentVC, animated: true, completion: {() -> Void in
            self.setCornerRadius(cornerRadius, recursiveFor: contentVC.view.superview)
        })
    }

    func dismiss() {
        dismiss(animated: true) { _ in }
    }
}

extension HLCommonVC {
    func hl_loadView() {
        if responds(to: #selector(self.loadViewIfNeeded)) {
            loadViewIfNeeded()
        }
        else {
            view
        }
    }
}