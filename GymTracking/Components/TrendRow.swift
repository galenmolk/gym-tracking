import SwiftUI

struct TrendRow: View {
    let label: String
    let value: String
    let sentiment: Sentiment?

    init(label: String, value: String, sentiment: Sentiment? = nil) {
        self.label = label
        self.value = value
        self.sentiment = sentiment
    }

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
            if let sentiment {
                Image(systemName: sentiment.systemImage)
                    .foregroundStyle(sentiment.color)
            }
        }
    }
}
