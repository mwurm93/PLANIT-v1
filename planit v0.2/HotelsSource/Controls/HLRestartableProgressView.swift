//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

private let animationDuration: TimeInterval = 0.3

class HLRestartableProgressView: UIView {
    var progressColor: UIColor? {
        get {
            return progressBar.backgroundColor!
        }
        set(progressBarColor) {
            progressBar.backgroundColor = progressBarColor
        }
    }
    var isShouldHideOnCompletion: Bool = false

    var displayLink: CADisplayLink?
    var currentProgress: CGFloat = 0.0
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarConstraint: NSLayoutConstraint!
    var progressBlock: ((_: Void) -> CGFloat)? = nil

    func start(withProgressBlock progressBlock: @escaping (_: Void) -> CGFloat) {
        self.progressBlock = progressBlock
        currentProgress = 0.0
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(self.updateProgress))
        displayLink?.add(to: RunLoop.mainRunLoop, forMode: NSRunLoopCommonModes)
        progressBarConstraint.constant = 0.0
        setNeedsLayout()
    }

    func stop() {
        progressChanged(1.0)
    }

    func updateProgress() {
        let progress: CGFloat = progressBlock()
        progressChanged(progress)
    }

    func progressChanged(_ progress: CGFloat) {
        if currentProgress() > 0.999 {
            isHidden = isShouldHideOnCompletion
            displayLink?.invalidate()
        }
        else {
            isHidden = false
        }
        let delta: CGFloat? = (progress - currentProgress()) * (displayLink?.duration / animationDuration)
        currentProgress += delta
        progressBarConstraint.constant = frame.size.width * currentProgress()
        setNeedsLayout()
    }
}