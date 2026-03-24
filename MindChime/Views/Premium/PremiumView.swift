import StoreKit
import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreKitService.shared
    @State private var selectedProductID: String? = nil

    private let features: [PremiumFeature] = [
        PremiumFeature(icon: "infinity", color: .blue, title: "Unlimited Habits", subtitle: "Track as many daily habits as you want"),
        PremiumFeature(icon: "bell.badge.fill", color: .orange, title: "Unlimited Chimes", subtitle: "Set as many wake-up alarms as you want"),
        PremiumFeature(icon: "book.pages.fill", color: .purple, title: "Daily Journal", subtitle: "Reflect and grow with guided daily entries"),
        PremiumFeature(icon: "quote.opening", color: .indigo, title: "Custom Quotes", subtitle: "Add your own personal quotes and wisdom"),
        PremiumFeature(icon: "chart.bar.fill", color: .green, title: "Advanced Analytics", subtitle: "Deep insights into your habit consistency"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .symbolEffect(.pulse)

                        Text("MindChime Premium")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Unlock your full potential for mindful living")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    // Feature list
                    VStack(spacing: 10) {
                        ForEach(features) { feature in
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(feature.color.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: feature.icon)
                                        .font(.body)
                                        .foregroundStyle(feature.color)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(feature.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.body)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.background, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)

                    if store.isPremium {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Text("You're a Premium member!")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    } else {
                        // Pricing cards
                        VStack(spacing: 10) {
                            if store.products.isEmpty {
                                ProgressView("Loading plans...")
                                    .padding()
                            } else {
                                ForEach(store.products, id: \.id) { product in
                                    PricingCard(
                                        product: product,
                                        isSelected: selectedProductID == product.id,
                                        isBestValue: product.id == StoreKitService.annualID
                                    ) {
                                        selectedProductID = product.id
                                    }
                                }
                                .onAppear {
                                    if selectedProductID == nil {
                                        selectedProductID = store.annualProduct?.id ?? store.products.first?.id
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Purchase button
                        VStack(spacing: 12) {
                            Button {
                                guard let id = selectedProductID,
                                      let product = store.products.first(where: { $0.id == id }) else { return }
                                Task { await store.purchase(product) }
                            } label: {
                                Group {
                                    if store.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Subscribe Now")
                                            .font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(store.isLoading || selectedProductID == nil)
                            .padding(.horizontal)

                            Button("Restore Purchases") {
                                Task { await store.restorePurchases() }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }

                        if let error = store.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Text("Subscriptions auto-renew. Cancel anytime in Settings > Apple ID > Subscriptions.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.headline)
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(.secondarySystemGroupedBackground))
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.accentColor, lineWidth: 2)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PremiumView()
}
