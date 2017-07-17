//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRResultsTicketPriceCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import AviasalesSDK
import SDWebImage
import UIKit

private let kCellHeight: CGFloat = 43
private let kAirlineLogoSize: CGSize = [85, 25]

class JRResultsTicketPriceCell: UITableViewCell {
    private var _price: JRSDKPrice?
    var price: JRSDKPrice? {
        get {
            return _price
        }
        set(price) {
            _price = price
            priceLabel.text = AviasalesNumberUtil.formatPrice(price.inUserCurrency())
        }
    }
    private var _airline: JRSDKAirline?
    var airline: JRSDKAirline? {
        get {
            return _airline
        }
        set(airline) {
            _airline = airline
            airlineLogoURL = URL(string: JRSDKModelUtils.airlineLogoUrl(withIATA: airline.iata, size: airlineLogoSize))
        }
    }

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    var airlineLogoSize = CGSize.zero
    private var _airlineLogoURL: URL?
    var airlineLogoURL: URL? {
        get {
            return _airlineLogoURL
        }
        set(airlineLogoURL) {
            if airlineLogoURL.isEqual(_airlineLogoURL) {
                return
            }
            _airlineLogoURL = airlineLogoURL
            if airlineLogoURL == nil {
                logoView.image() = nil
                return
            }
            logoView.image = nil
            logoView.isHidden = true
            weak var bself: JRResultsTicketPriceCell? = self
            logoView.sd_setImage(with: airlineLogoURL, placeholderImage: nil, completed: {(_ image: UIImage, _ error: Error?, _ cacheType: SDImageCacheType, _ imageURL: URL) -> Void in
                let sSelf: JRResultsTicketPriceCell? = bself
                if sSelf == nil {
                    return
                }
                if error != nil {
                    if error?.code == 404 {
                        MLOG("image with url %@ not found", airlineLogoURL.absoluteString)
                    }
                    else {
                        MLOG("unable to load image with url %@ (code %i)", airlineLogoURL.absoluteString, Int(error?.code))
                    }
                }
                else if sSelf?.airlineLogoURL?.isEqual(airlineLogoURL) {
                    sSelf?.self.logoView?.isHidden = false
                }
    
            })
        }
    }

    class func nibFileName() -> String {
        return "JRResultsTicketPriceCell"
    }

    class func height() -> CGFloat {
        return kCellHeight
    }

// MARK: - Getters

    override func awakeFromNib() {
        super.awakeFromNib()
        let scale: CGFloat = UIScreen.main.scale()
        airlineLogoSize = (CGSize)
        do {
            kAirlineLogoSize.width * scale, kAirlineLogoSize.height * scale
        }
    }

// MARK: - Setters
}