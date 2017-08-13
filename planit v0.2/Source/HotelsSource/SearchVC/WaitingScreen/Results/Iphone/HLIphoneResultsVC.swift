//
//  HLIphoneResultsVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 09/03/2017.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

import UIKit

class HLIphoneResultsVC: HLCommonResultsVC {

    var sortBottomDrawer: BottomDrawer?

    @IBOutlet weak var doneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = 5
        doneButton.backgroundColor = UIColor.orange
        
        self.view.backgroundColor = UIColor.clear
        self.view.layer.backgroundColor = UIColor.clear.cgColor
        self.view.tintColor = UIColor.clear
    }

    override func updateContentWithVariants(_ variants: [HLResultVariant], filteredVariants: [HLResultVariant]) {
        if let drawer = sortBottomDrawer {
            drawer.dismissDrawer()
        }
        super.updateContentWithVariants(variants, filteredVariants: filteredVariants)
    }

    override func presentSortVC(_ sortVC: HLSortVC, animated: Bool) {
        super.presentSortVC(sortVC, animated: animated)

        navigationController?.pushViewController(sortVC, animated: true)
    }

    // MARK: - HLPlaceholderViewDelegate Methods

    func moveToNewSearch() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func doneButtonTouchedUpInside(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelSearchResultsViewController_doneButtonTouchedUpInside"), object: nil)
    }
}
