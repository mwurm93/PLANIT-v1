//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

protocol HLGestureRecognizerDelegate: NSObjectProtocol {
    func recognizerCancelled()

    func recognizerStarted()

    func recognizerFinished()
}

class HLTapGestureRecognizer: UILongPressGestureRecognizer {
    weak var stateDelegate: HLGestureRecognizerDelegate?

    private var didMove: Bool = false
    private var started: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches as? Set<UITouch> ?? Set<UITouch>(), with: event)
        didMove = false
        if delegate?.gestureRecognizerShouldBegin(self) {
            stateDelegate?.recognizerStarted()
            started = true
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches as? Set<UITouch> ?? Set<UITouch>(), with: event)
        if started {
            stateDelegate?.recognizerCancelled()
        }
        started = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches as? Set<UITouch> ?? Set<UITouch>(), with: event)
        let touch: UITouch? = touches.first
        let location: CGPoint? = touch?.location(in: view)
        let previousLocation: CGPoint? = touch?.previousLocation(in: view)
        if !location.equalTo(previousLocation) {
            if started {
                stateDelegate?.recognizerCancelled()
                didMove = true
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches as? Set<UITouch> ?? Set<UITouch>(), with: event)
        if didMove {
            stateDelegate?.recognizerCancelled()
        }
        else if started {
            stateDelegate?.recognizerFinished()
        }

        started = false
    }
}