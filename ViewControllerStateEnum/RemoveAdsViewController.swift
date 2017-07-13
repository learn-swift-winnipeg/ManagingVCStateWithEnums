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
    case fetching // Getting the in-app purchase item's name/price to display
    case notPurchased // The user has not purchased the IAP, or needs to restore their previous purchase
    case purchasing // The purchase is in progress
    case purchased // The purchase has completed successfully
    case restoring // Restore purchases is in progress
    case restored // A previous purchase has been restored successfully
    
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

//MARK: - ToggleAlertsButtonState
/// This could have been handled with a boolean, but this shows an alternative typed way of handling the button's state.
fileprivate enum ToggleAlertsButtonState {
    case on, off
    
    fileprivate var buttonTitle: String {
        switch self {
        case .on: return "alerts (on)".capitalized
        case .off: return "alerts (off)".capitalized
        }
    }
    
    fileprivate var nextStateOnTap: ToggleAlertsButtonState {
        switch self {
        case .on: return .off
        case .off: return .on
        }
    }
    
    fileprivate var shouldShowAlert: Bool {
        switch self {
        case .on: return true
        case .off: return false
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
    @IBOutlet private weak var toggleAlertsButton: UIBarButtonItem!
    //MARK: Properties
    private var product: IAPProduct?
    /// This state needs to be stored so we know what the previous state is to change it
    private var toggleAlertsButtonState: ToggleAlertsButtonState = .on
    
    //MARK: UIViewController
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// If the in-app purchase was previously purchased, immediately transition to the purchased state, otherwise fetch the in-app purchase product data.
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
        
        toggleAlertsButton.title = toggleAlertsButtonState.buttonTitle
    }
    
    //MARK: Updates
    
    /// Updates the in-app purchase label to reflect the product that was fetched.
    private func update(with product: IAPProduct) {
        self.product = product
        productInfoLabel.text = "\(product.name): $\(product.price)"
    }
    
    /// This transition function takes a view controller state and mutates the view controller with the appropriate values for each element in the view.
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
        
        /// Tell the view it needs to re-layout, and animate the layout if animated is true.
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: IBActions
    
    /// Transitions to purchasing and requests a new purchase transaction. It transitions to the correct state of the in app purchase result.
    @IBAction private func removeAdsButtonTapped() {
        transition(to: .purchasing)
        
        IAPController.shared.requestTransaction(.newPurchase, onCompletion: { [weak self] result in
            switch result {
            case .noPurchaseToRestore, .restoredPurchase, .restoreFailed(_):
                break
            case .purchaseCompleted:
                self?.transition(to: .purchased)
                self?.showOKAlertIfNeeded(for: result)
            case .purchaseFailed(_):
                self?.transition(to: .notPurchased)
                self?.showOKAlertIfNeeded(for: result)
            }
        })
    }
    
    /// Transitions to restoring and requests a restore purchases transaction. It transitions to the correct state of the in app purchase result.
    @IBAction private func restorePurchasesButtonTapped() {
        transition(to: .restoring)
        
        IAPController.shared.requestTransaction(.restorePurchases, onCompletion: { [weak self] result in
            switch result {
            case .purchaseCompleted, .purchaseFailed(_):
                break
            case .noPurchaseToRestore:
                self?.transition(to: .notPurchased)
                self?.showOKAlertIfNeeded(for: result)
            case .restoredPurchase:
                self?.transition(to: .restored)
                self?.showOKAlertIfNeeded(for: result)
            case .restoreFailed(_):
                self?.transition(to: .notPurchased)
                self?.showOKAlertIfNeeded(for: result)
            }
        })
    }
    
    @IBAction private func doneButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction private func toggleAlertsButtonTapped() {
        toggleAlertsButtonState = toggleAlertsButtonState.nextStateOnTap
        toggleAlertsButton.title = toggleAlertsButtonState.buttonTitle
    }
    
    //MARK: Fetching
    
    /// Simulates the data fetch of the in-app purchasing product available for this app. It updates the view controller with the appropriate state upon completion.
    private func fetchIAPProduct() {
        transition(to: .fetching, animated: false)
        
        IAPController.shared.requestIAPProduct(onCompletion: { [weak self] product in
            self?.update(with: product)
            self?.transition(to: .notPurchased)
        })
    }
    
    //MARK: Alert Helper
    private func showOKAlertIfNeeded(for result: IAPTransactionResult) {
        /// Make sure the user wants to see alerts, otherwise don't show one
        guard toggleAlertsButtonState.shouldShowAlert else { return }
        
        let alert = UIAlertController(title: result.alertTitle, message: result.alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".uppercased(), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

//MARK: - RemoveAdsResult Extension

/// An extension that provides the appropriate title and message for the OK Alert for each IAP result type
fileprivate extension IAPTransactionResult {
    fileprivate var alertTitle: String {
        switch self {
        case .purchaseCompleted: return "purchase completed!".capitalized
        case .restoredPurchase: return "purchase restored!".capitalized
        case .noPurchaseToRestore: return "no purchase found".capitalized
        case .purchaseFailed(let errorMsg), .restoreFailed(let errorMsg):
            return errorMsg
        }
    }
    
    fileprivate var alertMessage: String? {
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

















