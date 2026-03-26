import SwiftUI

struct SentimentPicker: View {
    @Binding var selection: Sentiment
    @Namespace private var namespace

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                glassBody
            } else {
                legacyBody
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
    }

    @available(iOS 26, *)
    private var glassBody: some View {
        Picker("Sentiment", selection: $selection) {
            ForEach(Sentiment.allCases, id: \.self) { sentiment in
                Text(sentiment.label)
                    .tag(sentiment)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .tint(selection.color)
    }

    private var legacyBody: some View {
        HStack(spacing: 0) {
            ForEach(Sentiment.allCases, id: \.self) { sentiment in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = sentiment
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: sentiment.systemImage)
                            .font(.title3)
                        Text(sentiment.label)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(selection == sentiment ? sentiment.color : .secondary)
                    .fontWeight(selection == sentiment ? .semibold : .regular)
                    .background {
                        if selection == sentiment {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(sentiment.color.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(sentiment.color.opacity(0.5), lineWidth: 1)
                                )
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 56)
        .padding(3)
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
