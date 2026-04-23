//
//  TransactionError.swift
//  Stocking
//
//  Created by Heryan Djaruma on 23/04/26.
//


/// Transaction Error to be thrown from top of Screen and passed down to views
import Foundation

enum TransactionError: LocalizedError {
    case insufficientFunds, invalidQuantity
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds: return "You don't have enough balance"
        case .invalidQuantity: return "You don't have this amount of stock"
        }
    }
}

struct TransactionAlert: Identifiable {
    let id = UUID()
    let message: String
}
