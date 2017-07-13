//
//  IAPController.swift
//  ViewControllerStateEnum
//
//  Created by Justin Stanley on 2017-07-10.
//  Copyright © 2017 Justin Stanley. All rights reserved.
//

import Foundation

//MARK: - IAPTransactionType
internal enum IAPTransactionType {
    case newPurchase
    case restorePurchases
}


//MARK: - IAPTransactionResult
internal enum IAPTransactionResult {
    case purchaseCompleted
    case purchaseFailed(errorMsg: String) // Ideally would store (error: Error)
    case restoredPurchase
    case noPurchaseToRestore
    case restoreFailed(errorMsg: String) // Ideally would store (error: Error)
}

//MARK: - IAPRemoveAdsState
internal enum IAPRemoveAdsState {
    case notPurchased
    case purchased
    case unknown
    
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
internal class IAPController {
    //MARK: Singleton
    internal static let shared = IAPController()
    //MARK: Properties
    internal private(set) var removeAdsState: IAPRemoveAdsState = .unknown
    
    private init() {
        // Load the state from user defaults and set it.
    }
    
    internal func transition(to state: IAPRemoveAdsState) {
        removeAdsState = state
        
        // Save state to user defaults to check at app launch.
        // Hide Ad Banner throughout app if state is `.purchased`.
    }
    
    // Simulates a network call to get an in-app purchase product.
    internal func requestIAPProduct(onCompletion: @escaping (IAPProduct) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onCompletion(IAPProduct(id: "1007", name: "Remove Ads", price: 3.99))
        }
    }
    
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
    
    private func randomNewPurchaseTransactionResult() -> IAPTransactionResult {
        return [IAPTransactionResult.purchaseCompleted,
                .purchaseFailed(errorMsg: "Error Code 2253: Item is currently not purchasable.")]
            .randomElement!
    }
    
    private func randomRestorePurchasesTransactionResult() -> IAPTransactionResult {
        return [IAPTransactionResult.restoredPurchase,
                .noPurchaseToRestore,
                .restoreFailed(errorMsg: "Error Code 1456: Could Not Authorize User.")]
            .randomElement!
    }
}

//MARK: - IAPProduct
internal struct IAPProduct {
    let id: String
    let name: String
    let price: Double
}














