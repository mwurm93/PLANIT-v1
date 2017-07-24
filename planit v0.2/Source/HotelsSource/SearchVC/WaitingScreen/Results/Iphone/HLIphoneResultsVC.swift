//
//  HLIphoneResultsVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 09/03/2017.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

import UIKit

class HLIphoneResultsVC: HLCommonResultsVC {

    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapDrawerButton: UIButton!

    var sortBottomDrawer: BottomDrawer?

    override func viewDidLoad() {
        super.viewDidLoad()

        sortButton.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
        sortButton.setTitleColor(JRColorScheme.mainButtonTitleColor(), for: .normal)
        
        mapDrawerButton.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
        mapDrawerButton.setTitleColor(JRColorScheme.mainButtonTitleColor(), for: .normal)
        mapDrawerButton.addTarget(self, action: #selector(super.showMap), for: UIControlEvents.touchUpInside)
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

}
