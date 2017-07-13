//
//  AdBannerViewController.swift
//  ViewControllerStateEnum
//
//  Created by Justin Stanley on 2017-07-10.
//  Copyright © 2017 Justin Stanley. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum AdBannerViewControllerState {
    case bannerShowing
    case bannerHidden
    
    fileprivate init(removeAdsState: IAPRemoveAdsState) {
        switch removeAdsState {
        case .notPurchased, .unknown: self = .bannerShowing
        case .purchased: self = .bannerHidden
        }
    }
    
    fileprivate var zeroHeightBannerContainerConstraintPriority: UILayoutPriority {
        switch self {
        case .bannerShowing: return 250
        case .bannerHidden: return 999
        }
    }
    
    fileprivate var animated: Bool {
        switch self {
        case .bannerShowing: return true
        case .bannerHidden: return false
        }
    }
}

internal final class AdBannerViewController: UIViewController {
    @IBOutlet private weak var adBannerContainer: UIView!
    @IBOutlet private weak var zeroHeightBannerContainerConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let vcState = AdBannerViewControllerState(removeAdsState: IAPController.shared.removeAdsState)
        transition(to: vcState)
    }
    
    private func transition(to state: AdBannerViewControllerState) {
        UIView.animate(withDuration: state.animated ? 0.25 : 0) {
            self.zeroHeightBannerContainerConstraint.priority = state.zeroHeightBannerContainerConstraintPriority
            self.adBannerContainer.layoutIfNeeded()
        }
    }
    
    @IBAction func resetIAPButtonTapped() {
        transition(to: .bannerShowing)
        IAPController.shared.transition(to: .notPurchased)
    }
}










