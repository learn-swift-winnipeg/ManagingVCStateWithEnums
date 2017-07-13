//
//  RemoveAdsViewController.swift
//  ViewControllerStateEnum
//
//  Created by Justin Stanley on 2017-07-09.
//  Copyright © 2017 Justin Stanley. All rights reserved.
//

import Foundation
import UIKit

//MARK: - RemoveAdsViewControllerState
fileprivate enum RemoveAdsViewControllerState {
    case fetching
    case notPurchased
    case purchasing
    case purchased
    case restoring
    case restored
    
    fileprivate var purchaseButtonTitle: String {
        switch self {
        case .purchased: return "purchased!".capitalized
        case .purchasing: return "Waiting for Confirmation..."
        case .restored: return "previously purchased!".capitalized
        case .notPurchased, .restoring, .fetching:
            return "purchase".capitalized
        }
    }
    
    fileprivate var purchaseButtonIsEnabled: Bool {
        switch self {
        case .notPurchased: return true
        case .purchased, .purchasing, .restored, .restoring, .fetching:
            return false
        }
    }
    
    fileprivate var purchaseButtonAlpha: CGFloat {
        switch self {
        case .notPurchased: return 1
        case .purchased, .purchasing, .restored, .restoring, .fetching:
            return 0.7
        }
    }
    
    fileprivate var restoreButtonTitle: String {
        switch self {
        case .purchased, .purchasing, .notPurchased, .fetching:
            return "restore purchases".capitalized
        case .restored: return "successfully restored!".capitalized
        case .restoring: return "restoring previous purchase...".capitalized
        }
    }
    
    fileprivate var restoreButtonIsEnabled: Bool {
        switch self {
        case .notPurchased: return true
        case .purchased, .purchasing, .restored, .restoring, .fetching:
            return false
        }
    }
    
    fileprivate var restoreButtonAlpha: CGFloat {
        switch self {
        case .notPurchased: return 1
        case .purchased, .purchasing, .restored, .restoring, .fetching:
            return 0.7
        }
    }
    
    fileprivate var loadingIndicatorAlpha: CGFloat {
        switch self {
        case .fetching: return 1
        case .purchased, .purchasing, .restored, .restoring, .notPurchased:
            return 0
        }
    }
    
    fileprivate var productInfoAlpha: CGFloat {
        switch self {
        case .fetching, .purchased, .restored: return 0
        case .purchasing, .restoring, .notPurchased: return 1
        }
    }
    
    fileprivate var purchaseAreaViewAlpha: CGFloat {
        switch self {
        case .purchased, .restored: return 0
        case .fetching, .purchasing, .restoring, .notPurchased:
            return 1
        }
    }
    
    fileprivate var purchaseAreaViewHeightConstraintConstant: CGFloat {
        switch self {
        case .purchased, .restored: return 0
        case .fetching, .purchasing, .restoring, .notPurchased:
            return 138
        }
    }
    
    fileprivate var messageLabelText: String {
        switch self {
        case .purchased, .restored:
            return "Thank You for supporting BB Links! 🎉\n\nAds have been removed permanently.\n\nCheers!\nJustin"
        case .notPurchased, .fetching, .restoring, .purchasing:
            return "As an independent developer and coach, ads help pay for development, data maintenance, and hosting costs.\n\nIf you would rather not see any ads, use this one-time In-App Purchase to remove them permanently for around a cup of ☕️!"
        }
    }
    
    fileprivate var messageLabelFont: UIFont {
        switch self {
        case .purchased, .restored:
            return .systemFont(ofSize: 16)
        case .notPurchased, .fetching, .restoring, .purchasing:
            return .systemFont(ofSize: 14)
        }
    }
    
    fileprivate var bottomMessageLabelText: String {
        switch self {
        case .purchased, .restored:
            return "If you still see ads, please contact me using the Send Feedback button at the bottom of the main Settings screen."
        case .notPurchased, .fetching, .restoring, .purchasing:
            return "Already Purchased? Use the Restore button above to remove ads again after reinstalling the app, or installing on a new device."
        }
    }
}

//MARK: - RemoveAdsViewController
internal final class RemoveAdsViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var purchaseAreaView: UIView!
    @IBOutlet private weak var productInfoLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var removeAdsButton: UIButton!
    @IBOutlet private weak var restorePurchasesButton: UIButton!
    @IBOutlet private weak var bottomMessageLabel: UILabel!
    @IBOutlet private weak var purchaseAreaViewHeightConstraint: NSLayoutConstraint!
    //MARK: Properties
    private var product: IAPProduct?
    
    //MARK: UIViewController
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if IAPController.shared.removeAdsState.isPurchased {
            transition(to: .purchased, animated: false)
        } else {
            fetchIAPProduct()
        }
    }
    
    //MARK: Setup
    private func setupViews() {
        [removeAdsButton, restorePurchasesButton].forEach {
            $0!.addCornersAndShadow(cornerType: .slightlyRounded(radius: CornerType.defaultRadius))
        }
    }
    
    //MARK: Updates
    private func update(with product: IAPProduct) {
        self.product = product
        productInfoLabel.text = "\(product.name): $\(product.price)"
    }
    
    fileprivate func transition(to state: RemoveAdsViewControllerState, animated: Bool = true) {
        
        //TODO: Move this into the IAPController instead
        switch state {
        case .purchased, .restored: IAPController.shared.transition(to: .purchased)
        case .fetching, .notPurchased, .restoring, .purchasing: break
        }
        
        removeAdsButton.setTitle(state.purchaseButtonTitle, for: .normal)
        removeAdsButton.isEnabled = state.purchaseButtonIsEnabled
        removeAdsButton.alpha = state.purchaseButtonAlpha
        
        restorePurchasesButton.setTitle(state.restoreButtonTitle, for: .normal)
        restorePurchasesButton.isEnabled = state.restoreButtonIsEnabled
        restorePurchasesButton.alpha = state.restoreButtonAlpha
        
        loadingIndicator.alpha = state.loadingIndicatorAlpha
        
        productInfoLabel.alpha = state.productInfoAlpha
        
        purchaseAreaView.alpha = state.purchaseAreaViewAlpha
        purchaseAreaViewHeightConstraint.constant = state.purchaseAreaViewHeightConstraintConstant
        
        messageLabel.font = state.messageLabelFont
        messageLabel.text = state.messageLabelText
        
        bottomMessageLabel.text = state.bottomMessageLabelText
        
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: IBActions
    @IBAction private func removeAdsButtonTapped() {
        transition(to: .purchasing)
        
        IAPController.shared.requestTransaction(.newPurchase, onCompletion: { [weak self] result in
            switch result {
            case .noPurchaseToRestore, .restoredPurchase, .restoreFailed(_):
                break
            case .purchaseCompleted:
                self?.transition(to: .purchased)
                self?.showOKAlert(for: result)
            case .purchaseFailed(_):
                self?.transition(to: .notPurchased)
                self?.showOKAlert(for: result)
            }
        })
    }
    
    @IBAction private func restorePurchasesButtonTapped() {
        transition(to: .restoring)
        
        IAPController.shared.requestTransaction(.restorePurchases, onCompletion: { [weak self] result in
            switch result {
            case .purchaseCompleted, .purchaseFailed(_):
                break
            case .noPurchaseToRestore:
                self?.transition(to: .notPurchased)
                self?.showOKAlert(for: result)
            case .restoredPurchase:
                self?.transition(to: .restored)
                self?.showOKAlert(for: result)
            case .restoreFailed(_):
                self?.transition(to: .notPurchased)
                self?.showOKAlert(for: result)
            }
        })
    }
    
    @IBAction private func doneButtonTapped() {
        self.dismiss(animated: true)
    }
    
    //MARK: Fetching
    private func fetchIAPProduct() {
        transition(to: .fetching, animated: false)
        
        IAPController.shared.requestIAPProduct(onCompletion: { [weak self] product in
            self?.update(with: product)
            self?.transition(to: .notPurchased)
        })
    }
    
    //MARK: Alerts
    private func showOKAlert(for result: IAPTransactionResult) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".uppercased(), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

//MARK: - RemoveAdsResult Extension
fileprivate extension IAPTransactionResult {
    fileprivate var title: String {
        switch self {
        case .purchaseCompleted:
            return "purchase completed!".capitalized
        case .restoredPurchase:
            return "purchase restored!".capitalized
        case .noPurchaseToRestore:
            return "no purchase found".capitalized
        case .purchaseFailed(let errorMsg), .restoreFailed(let errorMsg):
            return errorMsg
        }
    }
    
    fileprivate var message: String? {
        switch self {
        case .purchaseCompleted, .restoredPurchase:
            return "Ads have been successfully removed! 🎉 Thank you!"
        case .noPurchaseToRestore:
            return "There was no previous purchase found to restore for this Apple ID."
        case .purchaseFailed(_), .restoreFailed(_):
            return nil
        }
    }
}

















