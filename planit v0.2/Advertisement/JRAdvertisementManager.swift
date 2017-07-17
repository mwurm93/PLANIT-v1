//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAdvertisementManager.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Appodeal
import Foundation

class JRAdvertisementManager: NSObject {
    var isShowsAdDuringSearch: Bool = false
    var isShowsAdOnSearchResults: Bool = false
    private(set) var cachedAviasalesAdView: UIView?

    var cachedAviasalesAdView: UIView?

    private var adLoaders = Set<AnyHashable>()

    class func sharedInstance() -> JRAdvertisementManager {
        var result: JRAdvertisementManager? = nil
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            result = JRAdvertisementManager()
        }
        onceToken = 1
        return result!
    }

    /**
     * @param testingEnabled Установите YES, чтобы загружать тестовую рекламу. Работает только в DEBUG режиме.
     *
     */
    func initializeAppodeal(withAPIKey appodealAPIKey: String, testingEnabled: Bool) {
#if DEBUG
        Appodeal.testingEnabled = testingEnabled
#endif
        Appodeal.initialize(withApiKey: appodealAPIKey, types: AppodealAdTypeInterstitial | AppodealAdTypeNativeAd)
    }

    func presentVideoAd(inViewIfNeeded view: UIView, rootViewController viewController: UIViewController) {
        if !isShowsAdDuringSearch {
            return
        }
        let videoLoader = JRVideoAdLoader()
        videoLoader.rootViewController = viewController
        let loaders: Set<AnyHashable> = adLoaders
        loaders.insert(videoLoader)
        weak var weakViewController: UIViewController? = viewController
        videoLoader.loadVideoAd({(_ adView: APDMediaView, _ ad: APDNativeAd) -> Void in
            loaders.remove(videoLoader)
            if adView != nil {
                view.addSubview(adView)
                adView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(JRConstraintsMakeScaleToFill(adView, view))
                ad.attach(to: view, viewController: viewController)
            }
            else {
                let viewController: UIViewController? = weakViewController
                if viewController && Appodeal.isReadyForShow(withStyle: AppodealShowStyleInterstitial) {
                    Appodeal.showAd(AppodealShowStyleInterstitial, rootViewController: viewController)
                }
            }
        })
    }

    func loadAndCacheAviasalesAdView(with searchInfo: JRSDKSearchInfo) {
        cachedAviasalesAdView = nil
        let loader = JRAviasalesAdLoader(searchInfo: searchInfo)
        weak var loaders: Set<AnyHashable>? = adLoaders
        loaders?.insert(loader)
        weak var weakself: JRAdvertisementManager? = self
        loader.loadAd(withCallback: {(_ adView: UIView) -> Void in
            loaders?.remove(loader)
            weakself?.self.cachedAviasalesAdView = adView
        })
    }

    override init() {
        super.init()

        isShowsAdDuringSearch = true
        isShowsAdOnSearchResults = false
        adLoaders = Set<AnyHashable>()
    
    }
}