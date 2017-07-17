//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRVideoAdLoader.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Appodeal
import Foundation

class JRVideoAdLoader: NSObject {
    weak var rootViewController: UIViewController?

    var nativeAdLoader: JRNativeAdLoader?

    func loadVideoAd(_ callback: @escaping (_: APDMediaView, _: APDNativeAd) -> Void) {
        if callback == nil {
            return
        }
        weak var bself: JRVideoAdLoader? = self
        nativeAdLoader?.loadAd(withType: APDNativeAdTypeVideo, callback: {(_ ad: APDNativeAd) -> Void in
            let sSelf: JRVideoAdLoader? = bself
            if sSelf == nil {
                return
            }
            if ad == nil || !ad.containsVideo {
                callback(nil, nil)
                return
            }
            var result: APDMediaView? = nil
            if sSelf?.self.rootViewController != nil {
                result = APDMediaView(frame: CGRect.zero)
                result?.type = APDMediaViewTypeMainImage
                result?.setNativeAd(ad, rootViewController: sSelf?.self.rootViewController)
            }
            callback(result, ad)
        })
    }

    override init() {
        super.init()

        nativeAdLoader = JRNativeAdLoader()
    
    }
}