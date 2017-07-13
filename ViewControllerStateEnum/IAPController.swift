//
//  IAPController.swift
//  ViewControllerStateEnum
//
//  Created by Justin Stanley on 2017-07-10.
//  Copyright © 2017 Justin Stanley. All rights reserved.
//

import Foundation

//MARK: - IAPTransactionType

/// A type indicating either requesting a new purchase transaction, or restoring a previous purchase
internal enum IAPTransactionType {
    case newPurchase
    case restorePurchases
}


//MARK: - IAPTransactionResult
internal enum IAPTransactionResult {
    case purchaseCompleted
    case purchaseFailed(errorMsg: String) // Ideally would store the IAP' Error instead
    case restoredPurchase
    case noPurchaseToRestore
    case restoreFailed(errorMsg: String) // Ideally would store the IAP's Error instead
}

//MARK: - IAPRemoveAdsState
internal enum IAPRemoveAdsState {
    case notPurchased // The in-app purchase has not been purchased
    case purchased // The in-app purchase has been purchased or restored
    case unknown // Initial unknown purchase state
    
    internal var isPurchased: Bool {
        switch self {
        case .purchased: return true
        case .notPurchased, .unknown: return false
        }
    }
    internal var hideAdBanner: Bool {
        switch self {
        case .purchased: return true
        case .notPurchased, .unknown: return false
        }
    }
}

//MARK: - IAPController

/// The In-App Purchase Controller stores the state of the in-app purchase, 
/// and handles all in-app purchase transactions.
internal class IAPController {
    //MARK: Singleton
    internal static let shared = IAPController()
    //MARK: Properties
    /// Can only be changed externally using transition method, but can be read using this property.
    internal private(set) var removeAdsState: IAPRemoveAdsState = .unknown
    
    private init() {
        /// Load the state from user defaults and set it.
    }
    
    //MARK: Updates
    internal func transition(to state: IAPRemoveAdsState) {
        removeAdsState = state
        
        /// Save state to user defaults to check at app launch.
        /// Hide Ad Banner throughout app if state is `.purchased`.
    }
    
    //MARK: Transaction Requests
    
    /// Simulates a network call to get an in-app purchase product.
    internal func requestIAPProduct(onCompletion: @escaping (IAPProduct) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onCompletion(IAPProduct(id: "1007", name: "Remove Ads", price: 3.99))
        }
    }
    
    /// Similates requesting a transaction from Apple, and returns the transaction result
    internal func requestTransaction(_ type: IAPTransactionType, onCompletion: @escaping (IAPTransactionResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            switch type {
            case .newPurchase:
                onCompletion(self.randomNewPurchaseTransactionResult())
            case .restorePurchases:
                onCompletion(self.randomRestorePurchasesTransactionResult())
            }
        }
    }
    
    //MARK: Helpers
    
    /// Returns one of the 2 random purchase transaction results
    private func randomNewPurchaseTransactionResult() -> IAPTransactionResult {
        return [IAPTransactionResult.purchaseCompleted,
                .purchaseFailed(errorMsg: "Error Code 2253: Item is currently not purchasable.")]
            .randomElement!
    }
    
    /// Returns one of the 3 random restore purchase transaction results
    private func randomRestorePurchasesTransactionResult() -> IAPTransactionResult {
        return [IAPTransactionResult.restoredPurchase,
                .noPurchaseToRestore,
                .restoreFailed(errorMsg: "Error Code 1456: Could Not Authorize User.")]
            .randomElement!
    }
}

//MARK: - IAPProduct

/// Simulates a simplified in-app purchase product
internal struct IAPProduct {
    let id: String
    let name: String
    let price: Double
}














