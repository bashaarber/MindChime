import SwiftUI

struct QuoteCardView: View {
    @Bindable var quote: Quote
    @State private var speechService = SpeechService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(quote.category.rawValue, systemImage: quote.category.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(quote.category.color)

                Spacer()

                Button {
                    withAnimation(.bouncy) {
                        quote.isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(quote.isFavorite ? .red : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(flexibility: .soft), trigger: quote.isFavorite)
            }

            Text(quote.text)
                .font(.body)
                .fontDesign(.serif)
                .lineSpacing(4)
                .foregroundStyle(.primary)

            HStack {
                Text("— \(quote.author)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    if speechService.isSpeaking {
                        speechService.stop()
                    } else {
                        AudioService.shared.playChimeSound()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            speechService.speak(quote.text, author: quote.author)
                        }
                    }
                } label: {
                    Image(systemName: speechService.isSpeaking ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title3)
                        .foregroundStyle(quote.category.color)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)

                ShareLink(
                    item: "\"\(quote.text)\" — \(quote.author)",
                    subject: Text("MindChime Thought"),
                    message: Text("Check out this thought from MindChime")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
