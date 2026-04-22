//
//  OrderSide.swift
//  Stocking
//
//  Created by Agustinus Juan Kurniawan on 22/04/26.
//


enum OrderSide: String, CaseIterable, Codable {
    case buy = "Buy"
    case sell = "Sell"
}

enum OrderType: String, CaseIterable, Codable {
    case limit = "Limit"
    case market = "Market"
}
