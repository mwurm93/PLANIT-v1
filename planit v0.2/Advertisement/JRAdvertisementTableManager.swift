//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAdvertisementTableManager.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

private let kCellReusableId: String = "JRAdvertisementTableManagerAdCell"
private let kAdViewTag: Int = 567134
private let kAviasalesAdHeight: CGFloat = 130
private let kHotelCardHeight: CGFloat = 155

class JRAdvertisementTableManager: NSObject, JRTableManager {
    var aviasalesAd: UIView?
    var hotelCard: JRHotelCardView?

// MARK: - <UITableViewDataSource>

    func numberOfSections(in tableView: UITableView) -> Int {
        let count: Int = 0
        if aviasalesAd != nil {
            count += 1
        }
        if hotelCard != nil {
            count += 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var adView: UIView?
        if indexPath.section == 0 && aviasalesAd != nil {
            adView = aviasalesAd
        }
        else {
            adView = hotelCard
        }
        var res: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: kCellReusableId)
        if res == nil {
            res = UITableViewCell()
        }
        else {
            res?.contentView?.viewWithTag(kAdViewTag)?.removeFromSuperview()
        }
        adView?.removeFromSuperview()
        adView?.frame = res?.contentView?.bounds
        adView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        res?.contentView?.addSubview(adView!)
        return res!
    }

// MARK: - <UITableViewDelegate>
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && aviasalesAd != nil {
            return kAviasalesAdHeight
        }
        else {
            return kHotelCardHeight
        }
    }
}