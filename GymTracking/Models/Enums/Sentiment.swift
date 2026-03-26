import SwiftUI

enum Sentiment: Int, Codable, CaseIterable {
    case decrease = 0
    case maintain = 1
    case increase = 2

    var label: String {
        switch self {
        case .decrease: "Decrease"
        case .maintain: "Maintain"
        case .increase: "Increase"
        }
    }

    var systemImage: String {
        switch self {
        case .decrease: "arrow.down.circle.fill"
        case .maintain: "checkmark.circle.fill"
        case .increase: "arrow.up.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .decrease: .orange
        case .maintain: .blue
        case .increase: .green
        }
    }
}
