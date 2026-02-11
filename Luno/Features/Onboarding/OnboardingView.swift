import SwiftUI

// MARK: - Onboarding View

// Welcome + Feature Tour onboarding flow (3 swipeable pages)
// Constitution: Clean design with existing Luno tokens

struct OnboardingView: View {
    // MARK: - Properties

    let appState: AppState
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        ZStack {
            LunoBackgroundView()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    voiceCapturePage.tag(1)
                    paraPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : MicroTransitions.smooth, value: currentPage)

                // Bottom controls
                bottomControls
                    .padding(.horizontal, LunoTheme.Spacing.xl)
                    .padding(.bottom, LunoTheme.Spacing.xl)
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: LunoTheme.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LunoColors.heroGradient.opacity(0.15))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(LunoColors.heroGradient.opacity(0.08))
                    .frame(width: 200, height: 200)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(LunoColors.heroGradient)
            }

            VStack(spacing: LunoTheme.Spacing.sm) {
                Text("Welcome to Luno")
                    .font(LunoTheme.Typography.displayMd)
                    .fontWeight(.bold)
                    .foregroundStyle(LunoColors.text0)

                Text("Your voice-first notebook")
                    .font(LunoTheme.Typography.title3)
                    .foregroundStyle(LunoColors.text1)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LunoTheme.Spacing.xl)
    }

    // MARK: - Page 2: Voice Capture

    private var voiceCapturePage: some View {
        VStack(spacing: LunoTheme.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LunoColors.heroGradient.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image(systemName: "mic.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(LunoColors.heroGradient)
            }

            VStack(spacing: LunoTheme.Spacing.sm) {
                Text("Capture thoughts instantly")
                    .font(LunoTheme.Typography.sectionTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LunoColors.text0)
                    .multilineTextAlignment(.center)

                Text("Speak naturally — Luno transcribes and organizes your notes automatically")
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.text1)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LunoTheme.Spacing.xl)
    }

    // MARK: - Page 3: PARA Organization

    private var paraPage: some View {
        VStack(spacing: LunoTheme.Spacing.lg) {
            Spacer()

            HStack(spacing: LunoTheme.Spacing.sm) {
                ForEach(PARACategory.paraCategories, id: \.self) { category in
                    CategoryBadge(category: category, style: .expanded)
                }
            }

            VStack(spacing: LunoTheme.Spacing.sm) {
                Text("Smart categorization")
                    .font(LunoTheme.Typography.sectionTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LunoColors.text0)
                    .multilineTextAlignment(.center)

                Text("Notes are automatically sorted into Projects, Areas, Resources & Archive")
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.text1)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LunoTheme.Spacing.xl)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            // Page indicator dots
            HStack(spacing: LunoTheme.Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? LunoColors.brand500 : LunoColors.text1.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(reduceMotion ? nil : MicroTransitions.fast, value: currentPage)
                }
            }

            // Action buttons
            HStack {
                if currentPage < 2 {
                    Button("Skip") {
                        appState.completeOnboarding()
                    }
                    .font(LunoTheme.Typography.body)
                    .foregroundStyle(LunoColors.text1)

                    Spacer()

                    Button {
                        withAnimation(reduceMotion ? nil : MicroTransitions.smooth) {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .font(LunoTheme.Typography.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, LunoTheme.Spacing.xl)
                            .padding(.vertical, LunoTheme.Spacing.sm)
                            .background(LunoColors.voiceButtonGradient)
                            .clipShape(Capsule())
                    }
                } else {
                    Button {
                        appState.completeOnboarding()
                    } label: {
                        Text("Get Started")
                            .font(LunoTheme.Typography.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LunoTheme.Spacing.md)
                            .background(LunoColors.voiceButtonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
                            .lunoGlassStroke(cornerRadius: LunoTheme.CornerRadius.button)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView(appState: AppState())
}
