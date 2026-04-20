import SwiftUI

enum PriceStatus {
    case rising, falling, neutral

    var color: Color {
        switch self {
        case .rising:  return .green
        case .falling: return .red
        case .neutral: return .gray
        }
    }
}
