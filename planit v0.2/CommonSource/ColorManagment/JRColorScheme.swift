//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRColorScheme.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRColorScheme: NSObject {
    class func color(fromConstant textColorConstant: String) -> UIColor {
        assert(!(textColorConstant == "colorFromConstant"), "Invalid parameter not satisfying: !(textColorConstant == "colorFromConstant")")
        var result: UIColor?
        let selector: Selector = NSSelectorFromString(textColorConstant)
        if self.responds(to: selector) {
            let imp: IMP = self.method(for: selector)
            UIColor * (`func`)(id, SEL) = (imp as? Void)
            result = `func`(self, selector)
        }
        else {
            print("tried to create color with unsupported constant \(textColorConstant)")
        }
        return result!
    }

    // Tint
    class func tintColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.tintColor!
    }

    // NavigationBar
    class func navigationBarBackgroundColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.navigationBarBackgroundColor()
    }

    class func navigationBarItemColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.navigationBarItemColor()
    }

    // MainButton
    class func mainButtonBackgroundColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.mainButtonBackgroundColor()
    }

    class func mainButtonTitleColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.mainButtonTitleColor()
    }

    // SearchForm
    class func searchFormTintColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.searchFormTintColor()
    }

    class func searchFormBackgroundColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.searchFormBackgroundColor()
    }

    class func searchFormTextColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.searchFormTextColor()
    }

    class func searchFormSeparatorColor() -> UIColor {
        return ColorSchemeConfigurator.shared.currentColorScheme.searchFormSeparatorColor()
    }

    //Background
    class func mainBackgroundColor() -> UIColor {
        return COLOR_WITH_RED(247, 247, 247)
    }

    class func lightBackgroundColor() -> UIColor {
        return UIColor.white
    }

    class func darkBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 82)
    }

    class func itemsBackgroundColor() -> UIColor {
        return UIColor.white
    }

    class func itemsSelectedBackgroundColor() -> UIColor {
        return COLOR_WITH_WHITE(230)
    }

    class func iPadSceneShadowColor() -> UIColor {
        return UIColor.black.withAlphaComponent(0.33)
    }

    // Slider
    class func sliderBackgroundColor() -> UIColor {
        return COLOR_WITH_RED(236, 239, 241)
    }

    //Tabs
    class func tabBarBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 88)
    }

    class func tabBarSelectedBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 85)
    }

    class func tabBarHighlightedBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 86)
    }

    //Text
    class func darkTextColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 38)
    }

    class func lightTextColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 67)
    }

    class func inactiveLightTextColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 66)
    }

    class func labelWithRoundedCornersBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 85)
    }

    class func separatorLineColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 59)
    }

    //Button
    class func buttonBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 85)
    }

    class func buttonSelectedBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 80)
    }

    class func buttonHighlightedBackgroundColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 80)
    }

    class func buttonShadowColor() -> UIColor {
        return COLOR_WITH_HUE(0, 0, 78)
    }

    //Popover
    class func popoverTintColor() -> UIColor {
        return UIColor.black.withAlphaComponent(0.7)
    }

    class func popoverBackgroundColor() -> UIColor {
        return UIColor.darkGray
    }

    //Rating stars
    class func ratingStarDefaultColor() -> UIColor {
        return COLOR_WITH_ALPHA(255, 155, 16, 0.4)
    }

    class func ratingStarSelectedColor() -> UIColor {
        return COLOR_WITH_RED(255, 154, 13)
    }

    //Filters
    class func sliderMinImage() -> UIImage {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        return UIImage(named: "JRSliderMinImg")?.imageTinted(with: self.darkBackgroundColor())?.resizableImage(withCapInsets: insets)!
    }

    class func sliderMaxImage() -> UIImage {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        return UIImage(named: "JRSliderMaxImg")?.imageTinted(with: self.navigationBarBackgroundColor())?.resizableImage(withCapInsets: insets)!
    }

    class func photoActivityIndicatorBackgroundColor() -> UIColor {
        return UIColor.clear
    }

    class func photoActivityIndicatorBorderColor() -> UIColor {
        return self.mainButtonBackgroundColor()
    }

    //Hotels
    class func hotelBackgroundColor() -> UIColor {
        return self.priceBackgroundColor()
    }

    class func discountColor() -> UIColor {
        return UIColor(red: 0.0, green: 166.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
    }

    class func priceBackgroundColor() -> UIColor {
        return UIColor(red: 70.0 / 255.0, green: 71.0 / 255.0, blue: 72.0 / 255.0, alpha: 1)
    }

// MARK: - Hotel details
    class func ratingColor(_ rating: Int) -> UIColor {
        if rating < 65 {
            return self.ratingRedColor()
        }
        else if rating <= 75 {
            return self.ratingYellowColor()
        }
        else {
            return self.ratingGreenColor()
        }

    }

// MARK: - Tint

// MARK: - NavigationBar

// MARK: - SearchForm

// MARK: - MainButton

// MARK: - Background

    //Filters

// MARK: - Hotel details

    class func ratingGreenColor() -> UIColor {
        return UIColor(red: 25.0 / 255.0, green: 154.0 / 255.0, blue: 17.0 / 255.0, alpha: 1.0)
    }

    class func ratingRedColor() -> UIColor {
        return UIColor(red: 243.0 / 255.0, green: 113.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    }

    class func ratingYellowColor() -> UIColor {
        return UIColor(red: 245.0 / 255.0, green: 166.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    }

// MARK: - Hotels
}

func COLOR_WITH_WHITE(A: Any) -> Any {
    return UIColor(white: (Float(A) / 255.0), alpha: 1)
}
func COLOR_WITH_RED(A: Any, B: Any, C: Any) -> Any {
    return COLOR_WITH_ALPHA(A, B, C, 1)
}
func COLOR_WITH_ALPHA(A: Any, B: Any, C: Any, D: Any) -> Any {
    return UIColor(red: Float(A) / 255.0, green: Float(B) / 255.0, blue: Float(C) / 255.0, alpha: Float(D))
}
func COLOR_WITH_PATTERN(A: Any) -> Any {
    return UIColor(patternImage: UIImage(named: A))
}
/**
 * H - 0..255
 * S - 0..100
 * B - 0..100
 */
func COLOR_WITH_HUE(H: Any, S: Any, B: Any) -> Any {
    return COLOR_WITH_HSBA(H, S, B, 1)
}
func COLOR_WITH_HSBA(H: Any, S: Any, B: Any, A: Any) -> Any {
    return UIColor(hue: H / 360.0, saturation: S / 100.0, brightness: B / 100.0, alpha: A)
}