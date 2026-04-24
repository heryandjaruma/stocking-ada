//
//  TransactionError.swift
//  Stocking
//
//  Created by Heryan Djaruma on 23/04/26.
//


/// Transaction Error to be thrown from top of Screen and passed down to views
import Foundation

enum TransactionError: LocalizedError {
    case insufficientFunds, insufficientStocks, stockNotOwned
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds: return "You don't have enough balance"
        case .insufficientStocks: return "You don't have this amount of stock"
        case .stockNotOwned: return "You don't own any amount of this stock"
        }
    }
}

struct TransactionAlert: Identifiable {
    let id = UUID()
    let message: String
    var type: AlertType = .error
    
    enum AlertType {
        case success, error
    }
}
