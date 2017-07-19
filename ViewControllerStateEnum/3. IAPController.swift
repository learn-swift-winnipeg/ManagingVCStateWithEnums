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
    
    // Returns a random transaction result for demo purposes
    fileprivate var randomTransactionResult: IAPTransactionResult {
        let possibleResults: [IAPTransactionResult]
        switch self {
        case .newPurchase:
            possibleResults = [.purchaseCompleted,
                               .purchaseFailed(errorMsg: "Error Code 2253: Item is currently not purchasable.")]
        case .restorePurchases:
            possibleResults = [.restoredPurchase,
                               .noPurchaseToRestore,
                               .restoreFailed(errorMsg: "Error Code 1456: Could Not Authorize User.")]
        }
        return possibleResults.randomElement!
    }
}

//MARK: - IAPTransactionResult
internal enum IAPTransactionResult {
    case purchaseCompleted
    case purchaseFailed(errorMsg: String) // Ideally would store the actual IAP's Error instead
    case restoredPurchase
    case noPurchaseToRestore
    case restoreFailed(errorMsg: String) // Ideally would store the actual IAP's Error instead
}

//MARK: - IAPRemoveAdsState
internal enum IAPRemoveAdsState {
    case notPurchased // The in-app purchase has not been purchased
    case purchased // The in-app purchase has been purchased or restored
    case unknown // Initial unknown purchase state
    
    fileprivate static let userDefaultsKey = "removeAdsIsPurchased"
    
    internal var isPurchased: Bool {
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
        /// Load the state from user defaults and set the local state to purchased if needed.
        let isPurchased = UserDefaults.standard.bool(forKey: IAPRemoveAdsState.userDefaultsKey)
        
        if isPurchased {
            removeAdsState = .purchased
        }
    }
    
    //MARK: Updates
    internal func transition(to state: IAPRemoveAdsState) {
        removeAdsState = state
        
        /// Save state to user defaults to check at app launch.
        UserDefaults.standard.set(state.isPurchased, forKey: IAPRemoveAdsState.userDefaultsKey)
    }
    
    //MARK: Transaction Requests
    
    /// Simulates a network call to get an in-app purchase product.
    internal func requestIAPProduct(onCompletion: @escaping (IAPProduct) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onCompletion(IAPProduct(id: "1007", name: "Remove Ads", price: 3.99))
        }
    }
    
    /// Similates requesting a transaction from Apple, setting the state in this controller based on the result, and returning the transaction result
    internal func requestTransaction(_ type: IAPTransactionType, onCompletion: @escaping (IAPTransactionResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = type.randomTransactionResult
            
            switch result {
            case .purchaseCompleted, .restoredPurchase:
                self.transition(to: .purchased)
            case .noPurchaseToRestore, .purchaseFailed(_), .restoreFailed(_):
                self.transition(to: .notPurchased)
            }
            
            onCompletion(result)
        }
    }
}

//MARK: - IAPProduct

/// Simulates a simplified in-app purchase product
internal struct IAPProduct {
    let id: String
    let name: String
    let price: Double
}
















