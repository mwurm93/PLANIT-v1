//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

enum HLSliderCalculatorRoundingRule : Int {
    case none = 0
    case floor = 1
    case ceil = 2
}


class HLSliderCalculator: NSObject {
    class func calculateExpValue(withSliderValue value: Double, minValue: Double, maxValue: Double) -> Double {
        var calcValue: CGFloat = exp(powf(value, 3) * log(2)) - 1
        calcValue = minValue + (maxValue - minValue) * calcValue
        return calcValue
    }

    class func calculateExpValue(withSliderValue value: Double, minValue: Double, maxValue: Double, roundingRule: HLSliderCalculatorRoundingRule) -> Double {
        var calcValue: Double = self.calculateExpValue(withSliderValue: value, minValue: minValue, maxValue: maxValue)
        if roundingRule != [] && calcValue > 100.0 {
            let roundedValue: Double = self.roundValue(calcValue, roundingRule: roundingRule)
            calcValue = min(max(roundedValue, minValue), maxValue)
        }
        return calcValue
    }

    class func calculateSliderLogValue(withValue value: Double, minValue: Double, maxValue: Double) -> Double {
        let normValue: Double = (value - minValue) / (maxValue - minValue)
        var calcValue: Double = (log(normValue + 1)) / log(2)
        calcValue = powf(calcValue, 1.0 / 3)
        return calcValue
    }

    class func roundValue(_ value: Double, roundingRule: HLSliderCalculatorRoundingRule) -> Double {
        var multiplier: Int = 1
        
        while value > 100.0 {
            value /= 10
            multiplier *= 10
        }
        switch roundingRule {
            case .ceil:
                value = ceilf(value)
            case .floor:
                value = floorf(value)
            default:
                break
        }

        value *= multiplier
        return value
    }
}