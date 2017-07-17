//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRNewsFeedAdLoader.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Appodeal
import Foundation

class JRNewsFeedAdLoader: NSObject {
    weak var rootViewController: UIViewController?

    var loader: JRNativeAdLoader?

    func loadAd(with size: CGSize, callback: @escaping (_: JRNewsFeedNativeAdView) -> Void) {
        weak var bself: JRNewsFeedAdLoader? = self
        loader?.loadAd(withType: APDNativeAdTypeNoVideo, callback: {(_ ad: APDNativeAd) -> Void in
            let sSelf: JRNewsFeedAdLoader? = bself
            if sSelf == nil {
                return
            }
            if ad == nil || !(ad.title? is String) || (ad.title.characters.count ?? 0) == 0 {
                callback(nil)
                return
            }
            var adView: JRNewsFeedNativeAdView? = nil
            if sSelf?.self.rootViewController != nil {
                adView = JRNewsFeedNativeAdView(nativeAd: ad)
                ad.attach(to: adView, viewController: sSelf?.self.rootViewController)
            }
            callback(adView)
        })
    }

    override init() {
        super.init()

        loader = JRNativeAdLoader()
    
    }
}