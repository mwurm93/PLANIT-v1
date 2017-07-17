//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRNewsFeedNativeAdView.swift
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 24.08.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

import Appodeal
import AXRatingView
import SDWebImage
import UIKit

private let kCallToActionCornerRadius: CGFloat = 3

class JRNewsFeedNativeAdView: UIView {
    private var _ad: APDNativeAd?
    var ad: APDNativeAd? {
        get {
            return _ad
        }
        set(ad) {
            _ad = ad
            if (ad.title? is String) {
                titleLabel.text = ad.title
            }
            else {
                titleLabel.text = ""
            }
            if (ad.subtitle? is String) && (ad.subtitle.characters.count ?? 0) > 0 {
                subtitleLabel.text = ad.subtitle
            }
            else if (ad.descriptionText? is String) && (ad.descriptionText.characters.count ?? 0) > 0 {
                subtitleLabel.text = ad.descriptionText
            }
            else {
                subtitleLabel.text = ""
            }
    
            ageRatingLabel.text = ""
            //Theare is no such parameter in native ad yet
            if (ad.iconImage? is APDImage) && (ad.iconImage.url? is URL) {
                iconImage?.sd_setImage(with: ad.iconImage.url)
            }
            if (self.ad.starRating is NSNumber) {
                ratingView.value = CFloat(self.ad.starRating)
            }
            else {
                ratingView.isHidden = true
            }
            if (ad.callToActionText is String) {
                callToActionLabel.text = ad.callToActionText
            }
            else {
                callToActionLabel.text = "GET"
            }
            for adChoicesContainerSubview: UIView in adChoicesContainerView.subviews {
                adChoicesContainerSubview.removeFromSuperview()
            }
            if (self.ad.adChoicesView is UIView) {
                self.ad.adChoicesView.frame = adChoicesContainerView.bounds
                self.ad.adChoicesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                adChoicesContainerView.addSubview(ad.adChoicesView)
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ageRatingLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var ratingView: AXRatingView!
    @IBOutlet weak var callToActionBorder: UIView!
    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var adChoicesContainerView: UIView!

    convenience init(nativeAd: APDNativeAd) {
        let view: JRNewsFeedNativeAdView? = LOAD_VIEW_FROM_NIB_NAMED("JRNewsFeedNativeAdView")
        view?.ad = nativeAd
        return view!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.isUserInteractionEnabled = false
        setupStyle()
    }

    deinit {
        ad.detachFromView()
    }

    func setupStyle() {
        titleLabel.textColor = JRColorScheme.darkText
        subtitleLabel.textColor = JRColorScheme.lightText
        ageRatingLabel.textColor = JRColorScheme.lightText
        callToActionBorder.layer.cornerRadius = kCallToActionCornerRadius
        callToActionBorder.layer.borderWidth = 1
        callToActionBorder.layer.borderColor = tintColor.cgColor
        callToActionLabel.textColor = tintColor
        ratingView.baseColor = JRColorScheme.ratingStarDefaultColor()
        ratingView.highlightColor = JRColorScheme.ratingStarSelectedColor()
        ratingView.markFont = UIFont.systemFont(ofSize: 8)
    }
}