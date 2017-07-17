//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAviasalesAdLoader.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import AviasalesSDK
import Foundation

class JRAviasalesAdLoader: NSObject {
    var searchInfo: JRSDKSearchInfo?
    var isLoadingAd: Bool = false
    var callback: ((_: UIView) -> Void)? = nil

    init(searchInfo: JRSDKSearchInfo) {
        super.init()

        self.searchInfo = searchInfo
    
    }

    /**
     * callback - returns nil if error occured
     */
    func loadAd(withCallback callback: @escaping (_ adView: UIView) -> Void) {
        if isLoadingAd {
            return
            //Loading has already started
        }
        if callback == nil {
            return
            //No need to load something
        }
        self.callback = callback
        isLoadingAd = true
        weak var weakSelf: JRAviasalesAdLoader? = self
        AviasalesSDK.sharedInstance.adsManager.loadAdsViewForSearchResults(with: searchInfo, completion: {(_ adsView: AviasalesSDKAdsView?, _ error: Error?) -> Void in
            if weakSelf?.callback {
                weakSelf?.callback(adsView)
            }
            weakSelf?.clean()
        })
    }

// MARK: - Private
    func clean() {
        callback = nil
        isLoadingAd = false
    }
}