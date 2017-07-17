//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

protocol HLDeceleratingProgressAnimatorDelegate: NSObjectProtocol {
    func progressChanged(_ progress: CGFloat)
}

class HLDeceleratingProgressAnimator: NSObject {
    private(set) var progress: CGFloat = 0.0
    weak var delegate: HLDeceleratingProgressAnimatorDelegate?

    var displayLink: CADisplayLink?
    private var _animationDuration = TimeInterval()
    var animationDuration: TimeInterval {
        get {
            return _animationDuration
        }
        set(animationDuration) {
            _animationDuration = animationDuration
            if _animationDuration < FLT_EPSILON {
                _animationDuration = FLT_EPSILON
            }
        }
    }
    var elapsedTime = TimeInterval()
    private var _progress: CGFloat = 0.0
    var progress: CGFloat {
        get {
            return _progress
        }
        set(progress) {
            _progress = progress
            delegate?.progressChanged(progress)
        }
    }
    var stoppedAtProgress: CGFloat = 0.0

    func start(withDuration duration: TimeInterval) {
        progress = 0.0
        elapsedTime = 0.0
        animationDuration = duration
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(self.updateProgress))
        displayLink?.add(to: RunLoop.mainRunLoop, forMode: NSRunLoopCommonModes)
    }

    func stop(withDuration duration: TimeInterval) {
        displayLink?.invalidate()
        stoppedAtProgress = progress
        elapsedTime = 0.0
        animationDuration = duration
        displayLink = CADisplayLink(target: self, selector: #selector(self.finishProgress))
        displayLink?.add(to: RunLoop.mainRunLoop, forMode: NSRunLoopCommonModes)
    }

    func updateProgress() {
        elapsedTime += displayLink?.duration
        progress = 0.95 * atan(elapsedTime / animationDuration * 2.0) / M_PI_2
    }

    func finishProgress() {
        elapsedTime += displayLink?.duration
        progress = max(0.0, min(stoppedAtProgress + (1.0 - stoppedAtProgress) * elapsedTime / animationDuration, 1.0))
        if progress >= 1.0 {
            displayLink?.invalidate()
        }
    }
}