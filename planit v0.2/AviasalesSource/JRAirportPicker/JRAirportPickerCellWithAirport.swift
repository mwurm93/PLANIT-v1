//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAirportPickerCellWithAirport.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let kIATAFontSize: CGFloat = 15

class JRAirportPickerCellWithAirport: JRTableViewCell {
    private var _airport: JRSDKAirport?
    var airport: JRSDKAirport? {
        get {
            return _airport
        }
        set(airport) {
            _airport = airport
            setupAirportLabel()
            setupIataCodeLabel()
        }
    }
    var searchString: String = ""

    @IBOutlet weak var cityAirportLabel: UILabel!
    @IBOutlet weak var iataCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cityAirportLabel.textColor = JRColorScheme.darkText
        iataCodeLabel.textColor = JRColorScheme.darkText
    }

    func setupIataCodeLabel() {
        let iataString: String = airport.iata.uppercased()
        let anyAirportRange: NSRange? = (iataCodeLabel.attributedText.string?.uppercased()? as NSString).range(of: NSLS("JR_ANY_AIRPORT").uppercased(), options: .caseInsensitive)
        let iataLabelColor: UIColor? = anyAirportRange?.location != NSNotFound ? JRColorScheme.darkText : JRColorScheme.lightText
        var attIataString: NSMutableAttributedString?
        if iataString != "" {
            attIataString = NSMutableAttributedString(string: iataString)
            let range = NSRange(location: 0, length: (iataString.characters.count ?? 0))
            attIataString?.addAttribute(NSForegroundColorAttributeName, value: iataLabelColor!, range: range)
            let searchStringsArray: [Any] = searchString.components(separatedBy: " ")
            for searchStringComponent: String in searchStringsArray {
                let iataRangeOfSearchString: NSRange = (searchStringComponent as NSString).range(of: iataString, options: [.caseInsensitive, .diacriticInsensitive])
                let font = iataRangeOfSearchString.location != NSNotFound ? UIFont.boldSystemFont(ofSize: kIATAFontSize) : UIFont.systemFont(ofSize: kIATAFontSize)
                attIataString?.addAttribute(NSFontAttributeName, value: font, range: range)
            }
        }
        iataCodeLabel.attributedText = attIataString as? NSAttributedString
    }

    func setupAirportLabel() {
        let cityString: String = airport.city
        let airportNameString: String = airport.localizedName
        let countryNameString: String = airport.countryName
        var airportCountryString = String()
        if (airportNameString.characters.count ?? 0) > 0 {
            airportCountryString += airportNameString
        }
        if (countryNameString.characters.count ?? 0) > 0 {
            if (airportCountryString.characters.count ?? 0) > 0 {
                airportCountryString += ", "
            }
            airportCountryString += countryNameString
        }
        cityAirportLabel.text = cityString
        countryLabel.text = airportCountryString
    }
}