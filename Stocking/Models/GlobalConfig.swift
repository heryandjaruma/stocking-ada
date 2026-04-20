//
//  GlobalConfig.swift
//  Stocking
//
//  Created by Heryan Djaruma on 20/04/26.
//

import SwiftUI
import SwiftData

@Model
class GlobalConfig {
    var id = UUID()
    var key: String
    var stringValue: String?
    var doubleValue: Double?
    var dateValue: Date?
    var boolValue: Bool?
    
    init(key: String, stringValue: String? = nil, doubleValue: Double? = nil, dateValue: Date? = nil, boolValue: Bool? = nil) {
        self.key = key
        self.stringValue = stringValue
        self.doubleValue = doubleValue
        self.dateValue = dateValue
        self.boolValue = boolValue
    }
}
