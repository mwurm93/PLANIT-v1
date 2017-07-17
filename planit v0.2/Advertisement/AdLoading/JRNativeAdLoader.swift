//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRNativeAdLoader.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Appodeal
import Foundation

class JRNativeAdLoader: NSObject, APDNativeAdLoaderDelegate {
    var appodeal: APDNativeAdLoader?
    var callback: ((_: APDNativeAd) -> Void)? = nil

    func loadAd(with type: APDNativeAdType, callback: @escaping (_: APDNativeAd) -> Void) {
        if callback == nil {
            return
        }
        if self.callback != nil {
            print("ad loading already started")
            return
        }
        self.callback = callback
        appodeal?.loadAd(with: type)
    }

    override init() {
        super.init()

        appodeal = APDNativeAdLoader()
        appodeal?.delegate = self
    
    }

// MARK: - <APDNativeAdLoaderDelegate>
    func nativeAdLoader(_ loader: APDNativeAdLoader, didLoadNativeAds nativeAds: [APDNativeAd]) {
        callback(nativeAds.first)
        clean()
    }

    func nativeAdLoader(_ loader: APDNativeAdLoader, didLoad nativeAd: APDNativeAd) {
        callback(nativeAd)
        clean()
    }

    func nativeAdLoader(_ loader: APDNativeAdLoader, didFailToLoadWithError error: Error?) {
        MLOG("error during native ad loading %@", error)
        callback(nil)
        clean()
    }

// MARK: - Private
    func clean() {
        callback = nil
        appodeal = nil
    }
}