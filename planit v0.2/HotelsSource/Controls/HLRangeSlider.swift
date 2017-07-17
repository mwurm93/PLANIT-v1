//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

protocol HLRangeSliderDelegate: NSObjectProtocol {
    func minValueChanged()

    func maxValueChanged()
}

class HLRangeSlider: UIControl {
    weak var delegate: HLRangeSliderDelegate?
    var lowerHandle: UIImageView?
    var upperHandle: UIImageView?
    // default 0.0
    var minimumValue: CGFloat = 0.0
    // default 1.0
    var maximumValue: CGFloat = 0.0
    // default 0.0. This is the minimum distance between between the upper and lower values
    var minimumRange: Float = 0.0
    // default 0.0 (disabled)
    var stepValue: Float = 0.0
    // If NO the slider will move freely with the tounch. When the touch ends, the value will snap to the nearest step value
    // If YES the slider will stay in its current position until it reaches a new step value.
    // default NO
    var isStepValueContinuously: Bool = false
    // defafult YES, indicating whether changes in the sliders value generate continuous update events.
    var isContinuous: Bool = false
    // default 0.0. this value will be pinned to min/max
    private var _lowerValue: CGFloat = 0.0
    var lowerValue: CGFloat {
        get {
            return _lowerValue
        }
        set(lowerValue) {
            var value: Float = lowerValue
            if stepValueInternal > 0 {
                value = roundf(value / stepValueInternal) * stepValueInternal
            }
            value = max(value, minimumValue)
            value = min(value, upperValue - minimumRange)
            _lowerValue = value
            setNeedsLayout()
        }
    }
    // default 1.0. this value will be pinned to min/max
    private var _upperValue: CGFloat = 0.0
    var upperValue: CGFloat {
        get {
            return _upperValue
        }
        set(upperValue) {
            var value: Float = upperValue
            if stepValueInternal > 0 {
                value = roundf(value / stepValueInternal) * stepValueInternal
            }
            value = min(value, maximumValue)
            value = max(value, lowerValue + minimumRange)
            _upperValue = value
            setNeedsLayout()
        }
    }
    // center location for the lower handle control
    var lowerCenter: CGPoint {
        return lowerHandle?.center!
    }
    // center location for the upper handle control
    var upperCenter: CGPoint {
        return upperHandle?.center!
    }
    // thumb image offset. If not set, use 13.0f
    var thumbImageOffset: CGFloat = 0.0
    // range slider horizontal offset. If not set, use 15.0f
    var rangeSliderHorizontalOffset: CGFloat = 0.0
    // Images, these should be set before the control is displayed.
    // If they are not set, then the default images are used.
    // eg viewDidLoad
    //Probably should add support for all control states... Anyone?
    var lowerHandleImageNormal: UIImage?
    var lowerHandleImageHighlighted: UIImage?
    var upperHandleImageNormal: UIImage?
    var upperHandleImageHighlighted: UIImage?
    var trackImage: UIImage?
    var trackBackgroundImage: UIImage?

    var track: UIImageView?
    var trackBackground: UIImageView?

    private var lowerTouchOffset: Float = 0.0
    private var upperTouchOffset: Float = 0.0
    private var stepValueInternal: Float = 0.0
    private var haveAddedSubviews: Bool = false

// MARK: Constructors

    func setLowerValue(_ lowerValue: Float, animated: Bool) {
        setLowerValue(lowerValue, upperValue: NAN, animated: animated)
    }

    func setUpperValue(_ upperValue: Float, animated: Bool) {
        setLowerValue(NAN, upperValue: upperValue, animated: animated)
    }

    func setLowerValue(_ lowerValue: Float, upperValue: Float, animated: Bool) {
        if (!animated) && (isnan(lowerValue) || lowerValue == self.lowerValue) && (isnan(upperValue) || upperValue == self.upperValue) {
            //nothing to set
            return
        }
        let setValuesBlock: ((_: Void) -> Void)? = {() -> Void in
                if !isnan(lowerValue) {
                    self.setLowerValue(lowerValue)
                }
                if !isnan(upperValue) {
                    self.setUpperValue(upperValue)
                }
            }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
                setValuesBlock()
                self.layoutSubviews()
            }) { _ in }
        }
        else {
            setValuesBlock()
            layoutSubviews()
        }
    }

    func addSubviews() {
        trackBackground = UIImageView(image: trackBackgroundImage)
        trackBackground?.frame = trackBackgroundRect()
        track = UIImageView(image: trackImage)
        track?.frame = trackRect
        lowerHandle = UIImageView(image: lowerHandleImageNormal, highlightedImage: lowerHandleImageHighlighted)
        lowerHandle?.contentMode = .center
        if (lowerHandleImageNormal?.size?.height < lowerHandleImageHighlighted?.size?.height) || (lowerHandleImageNormal?.size?.width < lowerHandleImageHighlighted?.size?.width) {
            lowerHandle?.frame = thumbRect(forValue: lowerValue, image: lowerHandleImageHighlighted)
        }
        else {
            lowerHandle?.frame = thumbRect(forValue: lowerValue, image: lowerHandleImageNormal)
        }
        upperHandle = UIImageView(image: upperHandleImageNormal, highlightedImage: upperHandleImageHighlighted)
        upperHandle?.contentMode = .center
        if (upperHandleImageNormal?.size?.height < upperHandleImageHighlighted?.size?.height) || (upperHandleImageNormal?.size?.width < upperHandleImageHighlighted?.size?.width) {
            lowerHandle?.frame = thumbRect(forValue: upperValue, image: upperHandleImageHighlighted)
        }
        else {
            lowerHandle?.frame = thumbRect(forValue: upperValue, image: upperHandleImageNormal)
        }
        addSubview(trackBackground!)
        addSubview(track!)
        addSubview(lowerHandle!)
        addSubview(upperHandle!)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureView()
    
    }

    func configureView() {
        minimumValue = 0.0
        maximumValue = 1.0
        minimumRange = 0.0
        stepValue = 0.0
        stepValueInternal = 0.0
        isContinuous = true
        lowerValue = 0.0
        upperValue = 1.0
        rangeSliderHorizontalOffset = 15.0
    }

// MARK: - Properties

// MARK: - Math
    //Returns the lower value based on the X potion
    //The return value is automatically adjust to fit inside the valid range
    func lowerValue(forCenterX x: Float) -> Float {
        let _padding: Float? = lowerHandle?.frame?.size?.width / 2.0
        var value: Float = minimumValue + (x - _padding) / (frame.size.width - (_padding * 2)) * (maximumValue - minimumValue)
        value = max(value, minimumValue)
        value = min(value, upperValue - minimumRange)
        return value
    }

    //Returns the upper value based on the X potion
    //The return value is automatically adjust to fit inside the valid range
    func upperValue(forCenterX x: Float) -> Float {
        let _padding: Float? = upperHandle?.frame?.size?.width / 2.0
        var value: Float = minimumValue + (x - _padding) / (frame.size.width - (_padding * 2)) * (maximumValue - minimumValue)
        value = min(value, maximumValue)
        value = max(value, lowerValue + minimumRange)
        return value
    }

    //returns the rect for the track image between the lower and upper values based on the trackimage object
    func trackRect() -> CGRect {
        var retValue: CGRect
        retValue.size = CGSize(width: trackImage?.size?.width, height: trackImage?.size?.height)
        let xLowerValue: Float? = (bounds.size.width - lowerHandle?.frame?.size?.width) * (lowerValue - minimumValue) / (maximumValue - minimumValue) + (lowerHandle?.frame?.size?.width / 3.0)
        let xUpperValue: Float? = (bounds.size.width - upperHandle?.frame?.size?.width) * (upperValue - minimumValue) / (maximumValue - minimumValue) + (upperHandle?.frame?.size?.width / 1.5)
        retValue.origin = CGPoint(x: xLowerValue!, y: (bounds.size.height / 2.0) - (retValue.size.height / 2.0))
        retValue.size.width = xUpperValue - xLowerValue
        retValue.origin = CGPoint(x: lowerHandle?.center?.x, y: (bounds.size.height / 2.0) - (retValue.size.height / 2.0))
        retValue.size.width = upperHandle?.frame?.origin?.x - lowerHandle?.frame?.origin?.x
        return retValue
    }

    //returns the rect for the background image
    func trackBackgroundRect() -> CGRect {
        var trackBackgroundRect: CGRect
        trackBackgroundRect.size = CGSize(width: trackBackgroundImage?.size?.width, height: trackBackgroundImage?.size?.height)
        if trackBackgroundImage?.capInsets?.top() || trackBackgroundImage?.capInsets?.bottom() {
            trackBackgroundRect.size.height = bounds.size.height
        }
        trackBackgroundRect.size.width = bounds.size.width - 2 * rangeSliderHorizontalOffset
        trackBackgroundRect.origin = CGPoint(x: rangeSliderHorizontalOffset, y: bounds.size.height / 2.0 - trackBackgroundRect.size.height / 2.0)
        return trackBackgroundRect
    }

    //returns the rect of the thumb image for a given track rect and value
    func thumbRect(forValue value: Float, image thumbImage: UIImage) -> CGRect {
        var thumbRect: CGRect
        thumbRect.size = thumbImage.size
        let b: Float = -HL_THUMB_IMAGE_OFFSET + rangeSliderHorizontalOffset
        let k: Float = frame.size.width - thumbImage.size.width + 2 * HL_THUMB_IMAGE_OFFSET - 2 * rangeSliderHorizontalOffset
        let xValue: Float = k * value + b
        thumbRect.origin = CGPoint(x: CGFloat(xValue), y: bounds.size.height / 2.0 - thumbRect.size.height / 2.0)
        return thumbRect
    }

// MARK: - Layout

    override func layoutSubviews() {
        if haveAddedSubviews == false {
            haveAddedSubviews = true
            addSubviews()
        }
        trackBackground?.frame = trackBackgroundRect()
        lowerHandle?.frame = thumbRect(forValue: lowerValue, image: lowerHandleImageNormal)
        upperHandle?.frame = thumbRect(forValue: upperValue, image: upperHandleImageNormal)
        track?.frame = trackRect()
        super.layoutSubviews()
    }

    func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: max(lowerHandleImageNormal?.size?.height, upperHandleImageNormal?.size?.height))!
    }

// MARK: - Touch handling
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -10, dy: -10).contains(point)
    }

    func touchRect(forLowerHandle handleImageView: UIImageView) -> CGRect {
        let rect: CGRect = extendedRect(forHandle: handleImageView)
        let deltaX: CGFloat = handlesCenter().x - handleImageView.center.x
        rect.origin.x -= max(HL_RANGE_SLIDER_WIDTH_EXTENSION / 2, HL_RANGE_SLIDER_WIDTH_EXTENSION - deltaX)
        return rect
    }

    func touchRect(forUpperHandle handleImageView: UIImageView) -> CGRect {
        let rect: CGRect = extendedRect(forHandle: handleImageView)
        let deltaX: CGFloat = handleImageView.center.x - handlesCenter().x
        rect.origin.x -= min(HL_RANGE_SLIDER_WIDTH_EXTENSION / 2, deltaX)
        return rect
    }

    func extendedRect(forHandle handleImageView: UIImageView) -> CGRect {
        let rect: CGRect = handleImageView.frame
        rect.size.width += HL_RANGE_SLIDER_WIDTH_EXTENSION
        rect.origin.y -= HL_RANGE_SLIDER_HEIGHT_EXTENSION / 2
        rect.size.height += HL_RANGE_SLIDER_HEIGHT_EXTENSION
        return rect
    }

    func handlesCenter() -> CGPoint {
        return CGPoint(x: (lowerHandle?.center?.x + upperHandle?.center?.x) / 2, y: (lowerHandle?.center?.y + upperHandle?.center?.y) / 2)!
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        let touchPoint: CGPoint? = touch?.location(in: self)
            //Check both buttons upper and lower thumb handles because
            //they could be on top of each other.
        let rect: CGRect = touchRect(forLowerHandle: lowerHandle)
        if rect.contains(touchPoint) {
            lowerHandle?.isHighlighted = true
            lowerTouchOffset = touchPoint?.x - lowerHandle?.center?.x
        }
        if touchRect(forUpperHandle: upperHandle).contains(touchPoint) {
            upperHandle?.isHighlighted = true
            upperTouchOffset = touchPoint?.x - upperHandle?.center?.x
        }
        stepValueInternal = isStepValueContinuously ? stepValue : 0.0
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !lowerHandle?.isHighlighted && !upperHandle?.isHighlighted {
            return
        }
        let touch: UITouch? = touches.first
        let touchPoint: CGPoint? = touch?.location(in: self)
        if lowerHandle?.isHighlighted {
                //get new lower value based on the touch location.
                //This is automatically contained within a valid range.
            let newValue: Float? = lowerValue(forCenterX: (touchPoint?.x - lowerTouchOffset))
            //if both upper and lower is selected, then the new value must be LOWER
            //otherwise the touch event is ignored.
            if !upperHandle?.isHighlighted || newValue < lowerValue {
                upperHandle?.isHighlighted = false
                bringSubview(toFront: lowerHandle!)
                setLowerValue(newValue, animated: isStepValueContinuously ? true : false)
            }
            else {
                lowerHandle?.isHighlighted = false
            }
        }
        if upperHandle?.isHighlighted {
            let newValue: Float? = upperValue(forCenterX: (touchPoint?.x - upperTouchOffset))
            //if both upper and lower is selected, then the new value must be HIGHER
            //otherwise the touch event is ignored.
            if !lowerHandle?.isHighlighted || newValue > upperValue {
                lowerHandle?.isHighlighted = false
                bringSubview(toFront: upperHandle!)
                setUpperValue(newValue, animated: isStepValueContinuously ? true : false)
            }
            else {
                upperHandle?.isHighlighted = false
            }
        }
        //send the control event
        if isContinuous {
            sendActions(for: .valueChanged)
            if lowerHandle?.isHighlighted {
                delegate?.minValueChanged()
            }
            if upperHandle?.isHighlighted {
                delegate?.maxValueChanged()
            }
        }
        setNeedsLayout()
    }

    override func cancelTracking(with event: UIEvent) {
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if stepValue > 0 {
            stepValueInternal = stepValue
            setLowerValue(lowerValue, animated: true)
            setUpperValue(upperValue, animated: true)
        }
        sendActions(for: .editingDidEnd)
        lowerHandle?.isHighlighted = false
        upperHandle?.isHighlighted = false
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lowerHandle?.isHighlighted = false
        upperHandle?.isHighlighted = false
        if stepValue > 0 {
            stepValueInternal = stepValue
            setLowerValue(lowerValue, animated: true)
            setUpperValue(upperValue, animated: true)
        }
        sendActions(for: .editingDidEnd)
    }
}

let HL_THUMB_IMAGE_OFFSET = 2.0
let HL_RANGE_SLIDER_WIDTH_EXTENSION = 100.0
let HL_RANGE_SLIDER_HEIGHT_EXTENSION = 80.0