import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "quote.opening",
            color: .indigo,
            title: "Daily Wisdom",
            subtitle: "Start each day inspired. Explore 75+ hand-picked quotes from philosophy, mindfulness, stoicism, and more."
        ),
        OnboardingPage(
            icon: "bell.fill",
            color: .orange,
            title: "Peaceful Chimes",
            subtitle: "Replace jarring alarms with a gentle chime and a meaningful thought. Good mornings start here."
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            color: .green,
            title: "Build Habits",
            subtitle: "Track daily habits, build streaks, and reflect in your journal. Transform your life one day at a time."
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.primary : Color.secondary.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(pages[currentPage].color)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .animation(.none, value: currentPage)

                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    } else {
                        Color.clear.frame(height: 20)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(page.color.opacity(0.06))
                    .frame(width: 200, height: 200)
                Image(systemName: page.icon)
                    .font(.system(size: 68, weight: .medium))
                    .foregroundStyle(page.color)
                    .symbolEffect(.pulse.byLayer)
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(5)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
