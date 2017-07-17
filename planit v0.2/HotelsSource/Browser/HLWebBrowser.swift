//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import QuartzCore
import WebKit

private var kAddressBarExpandedHeight: CGFloat = 64.0
private var kAddressBarCollapsedHeight: CGFloat = 40.0
private var kScrollActionLength: CGFloat = 24.0
private var kInitialFontSize: CGFloat = 19.0
private var kFinalFontSize: CGFloat = 12.0

protocol HLWebBrowserDelegate: NSObjectProtocol {
    func navigationFinished()

    func navigationFailed(_ error: Error?)

    func close()

    func reload()
}

class HLWebBrowser: UIView, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    weak var delegate: HLWebBrowserDelegate?
    private var _pageTitle: String = ""
    var pageTitle: String {
        get {
            return _pageTitle
        }
        set(pageTitle) {
            _pageTitle = pageTitle
            pageTitleLabel.text = pageTitle
        }
    }

    var urlRequest: URLRequest?
    var webView: WKWebView?
    var progressView: HLRestartableProgressView?
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var buttonGoBack: UIButton!
    @IBOutlet weak var buttonGoForward: UIButton!
    @IBOutlet weak var navigationViewOrigin: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var lockIcon: UIImageView!
    @IBOutlet weak var textBackground: UIView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var textAndLockView: UIView!
    @IBOutlet weak var textOrigin: NSLayoutConstraint!
    var lastScrollViewOffset: CGFloat = 0.0
    var initialScrollViewOffset: CGFloat = 0.0
    var hidingProgress: CGFloat = 0.0
    var isFinishedInitialLoading: Bool = false
    var webViewToSuperviewTop: NSLayoutConstraint?
    var webViewToSuperviewBottom: NSLayoutConstraint?
    var webViewToNavViewTop: NSLayoutConstraint?
    var webViewToBarViewBottom: NSLayoutConstraint?

// MARK: - Public

    func loadUrlString(_ urlString: String, scripts: [Any]) {
        urlRequest = URLRequest(url: URL(string: urlString))
        let userContentController = WKUserContentController()
        for script: String in scripts {
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            userContentController.addUserScript(userScript)
        }
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        weakify(self)
        hl_dispatch_main_async_safe({() -> Void in
            strongify(self)
            self.webView = self.webView(with: configuration)
            webView?.navigationDelegate = self
            webView?.uiDelegate = self
            self.insertSubview(self.webView!, at: 0)
            self.webView?.load(self.urlRequest!)
            self.webView?.autoPinEdge(toSuperviewEdge: ALEdgeLeading)
            self.webView?.autoPinEdge(toSuperviewEdge: ALEdgeTrailing)
            self.webViewToSuperviewTop = self.webView?.autoPinEdge(toSuperviewEdge: ALEdgeTop)
            self.webViewToSuperviewBottom = self.webView?.autoPinEdge(toSuperviewEdge: ALEdgeBottom)
            self.webViewToNavViewTop = self.webView?.autoPinEdge(ALEdgeTop, toEdge: ALEdgeBottom, of: self.addressView)
            if iPhone() {
                self.webViewToBarViewBottom = self.webView?.autoPinEdge(ALEdgeBottom, toEdge: ALEdgeTop, of: self.navigationView)
                webViewToBarViewBottom?.isActive = false
            }
            webViewToNavViewTop?.isActive = false
            webView?.scrollView?.self.delegate = self
            self.updateWebViewScrollBehavour()
        })
    }

    func stopProgress() {
        progressView?.stop()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addBlurEffectForBars()
        setupProgressBar()
        toggleBackForwardButtons()
        layoutIfNeeded()
        let webViewInsets: UIEdgeInsets? = webView?.scrollView?.contentInset
        webViewInsets?.bottom = navigationView.frame.size.height
        webView?.scrollView?.contentInset = webViewInsets
    }

    deinit {
        webView?.scrollView?.delegate = nil
    }

    func updateWebViewScrollBehavour() {
        let canAnimateScrollView: Bool? = canAnimate(webView?.scrollView)
        webViewToSuperviewTop?.isActive = canAnimateScrollView
        webViewToNavViewTop?.isActive = !canAnimateScrollView
        if iPhone() {
            webViewToSuperviewBottom?.isActive = canAnimateScrollView
            webViewToBarViewBottom?.isActive = !canAnimateScrollView
        }
        layoutIfNeeded()
    }

    func canAnimate(_ scrollView: UIScrollView) -> Bool {
        let contentSizeIsEqualToBounds: Bool = scrollView.contentSize.equalTo(scrollView.bounds.size)
        let contentIsEmpty: Bool = scrollView.contentSize.equalTo(CGSize.zero)
        return !(contentIsEmpty || contentSizeIsEqualToBounds)
    }

// MARK: - IBAction methods
    @IBAction func goBackward() {
        webView?.stopLoading()
        webView?.goBack()
        toggleBackForwardButtons()
    }

    @IBAction func goForward() {
        webView?.stopLoading()
        webView?.goForward()
        toggleBackForwardButtons()
    }

    @IBAction func close() {
        webView?.evaluateJavaScript("window.alert=null;", completionHandler: nil)
        webView?.stopLoading()
        delegate?.close()
    }

    @IBAction func reload() {
        if webView?.url {
            webView?.reload()
        }
        else {
            delegate?.reload()
        }
    }

// MARK: - Private
    func setupProgressBar() {
        progressView = LOAD_VIEW_FROM_NIB_NAMED("HLRestartableProgressView")
        addressView.addSubview(progressView!)
        progressView?.backgroundColor = UIColor.clear
        progressView?.progressColor = JRColorScheme.mainButtonBackgroundColor()
        progressView?.shouldHideOnCompletion = true
        progressView?.autoPinEdgesToSuperviewEdges(withInsets: UIEdgeInsetsZero, excludingEdge: ALEdgeTop)
        progressView?.autoSetDimension(ALDimensionHeight, toSize: 2.0)
    }

    func startShowProgress() {
        weakify(self)
        progressView?.start(withProgressBlock: {() -> CGFloat in
            strongify(self)
            return webView?.estimatedProgress
        })
    }

    func toggleBackForwardButtons() {
        let canGoForward: Bool? = webView?.canGoForward
        let canGoBackward: Bool? = webView?.canGoBack
        buttonGoBack.isEnabled = canGoBackward
        buttonGoForward.isEnabled = canGoForward
    }

    func addBlurEffectForBars() {
        for barView: UIView in [addressView, navigationView] {
            barView.addBlurEffect(with: .extraLight)
        }
    }

    func expandControls() {
        animateBars(toHidingProgress: 0.0)
    }

    func collapseControls() {
        animateBars(toHidingProgress: 1.0)
    }

    func animateBars(toHidingProgress progress: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState, .easeInOut], animations: {() -> Void in
            addressBarHideProgress = progress
            navBarHideProgress = progress
            self.updateInsets()
            self.layoutIfNeeded()
        }) { _ in }
    }

    func setAddressBarHideProgress(_ progress: CGFloat) {
        if !isFinishedInitialLoading {
            return
        }
        let alpha: CGFloat = 1 - progress
        closeButton.alpha = alpha
        reloadButton.alpha = alpha
        textBackground.alpha = alpha
        backwardButton.alpha = alpha
        forwardButton.alpha = alpha
        let newConstant: CGFloat = (1 - progress) * kAddressBarExpandedHeight + progress * kAddressBarCollapsedHeight
        addressViewHeight.constant = newConstant
        let textOriginY: CGFloat = progress * 11
        textOrigin.constant = textOriginY
        let ratio: CGFloat = 1 - (1 - kFinalFontSize / kInitialFontSize) * progress
        let scale = CGAffineTransform(scaleX: ratio, y: ratio)
        textAndLockView.transform = scale
        hidingProgress = progress
    }

    func setNavBarHideProgress(_ progress: CGFloat) {
        let newConstant: CGFloat = -progress * navigationView.frame.size.height
        navigationViewOrigin.constant = newConstant
    }

    func completeHiding(with scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.y
        if hidingProgress > 0.5 && offset > kScrollActionLength {
            collapseControls()
        }
        else {
            expandControls()
        }
    }

    func updateInsets() {
        let canAnimateScrollView: Bool? = canAnimate(webView?.scrollView)
        let previousValue: Bool? = webViewToSuperviewTop?.isActive
        if canAnimateScrollView != previousValue {
            updateWebViewScrollBehavour()
        }
        let webViewInsets: UIEdgeInsets? = webView?.scrollView?.contentInset
        webViewInsets?.top = canAnimateScrollView ? addressViewHeight.constant : 0
        webViewInsets?.bottom = canAnimateScrollView ? (navigationView.frame.size.height + navigationViewOrigin.constant) : 0
        webView?.scrollView?.contentInset = webViewInsets
        webView?.scrollView?.scrollIndicatorInsets = webViewInsets
        if canAnimateScrollView != previousValue {
            webView?.scrollView?.contentOffset = CGPoint(x: webView?.scrollView?.contentOffset?.x, y: -webViewInsets?.top())
        }
    }

// MARK: - HLWebView delegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView {
        if !navigationAction.targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        progressView?.stop()
        toggleBackForwardButtons()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        lockIcon.isHidden = !self.webView.hasOnlySecureContent
        updateWebViewScrollBehavour()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((int64_t)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            for script: WKUserScript in webView.configuration.userContentController.userScripts {
                webView.evaluateJavaScript(script.source, completionHandler: nil)
            }
        })
        isFinishedInitialLoading = true
        delegate?.navigationFinished()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error?) {
        progressView?.stop()
        isFinishedInitialLoading = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        expandControls()
        toggleBackForwardButtons()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        startShowProgress()
    }

// MARK: - Deeplink
    func webView(with configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: bounds, configuration: configuration)
        let webViewInsets: UIEdgeInsets = UIEdgeInsetsMake(kAddressBarExpandedHeight, 0.0, navigationView.frame.size.height, 0.0)
        webView.scrollView.contentInset = webViewInsets
        webView.scrollView.scrollIndicatorInsets = webViewInsets
        webView.scrollView.contentOffset = CGPoint(x: 0.0, y: webViewInsets.top())
        return webView
    }

// MARK: - UIScrollViewDelegate
    func scrollViewWillBeginScrolling(_ offset: CGFloat) {
        lastScrollViewOffset = offset
        initialScrollViewOffset = offset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.y
        if offset < (scrollView.contentSize.height - scrollView.bounds.size.height - (navigationView.bounds.size.height + navigationViewOrigin.constant)) {
            if offset > 0 {
                let delta: CGFloat = (offset - lastScrollViewOffset) / kScrollActionLength
                var progress: CGFloat = hidingProgress + delta
                progress = min(1.0, progress)
                progress = max(progress, 0.0)
                setAddressBarHideProgress(progress)
                setNavBarHideProgress(progress)
                updateInsets()
                lastScrollViewOffset = offset
            }
        }
        else {
            expandControls()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        completeHiding(with: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            completeHiding(with: scrollView)
        }
    }
}