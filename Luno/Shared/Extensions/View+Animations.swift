import SwiftUI

// MARK: - View Animation Extensions

// Animation helpers for consistent micro-transitions
// Constitution: Respect accessibility settings for motion

extension View {
    // MARK: - Conditional Animations

    /// Apply animation only if reduce motion is not enabled
    func animateIfAllowed(
        _ animation: Animation?,
        value: some Equatable
    ) -> some View {
        modifier(ConditionalAnimationModifier(animation: animation, value: value))
    }

    // MARK: - Fade Transitions

    /// Fade in on appear with optional delay
    func fadeInOnAppear(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    // MARK: - Slide Transitions

    /// Slide up on appear
    func slideUpOnAppear(offset: CGFloat = 20, delay: Double = 0) -> some View {
        modifier(SlideUpModifier(offset: offset, delay: delay))
    }

    // MARK: - Scale Transitions

    /// Scale in on appear
    func scaleInOnAppear(scale: CGFloat = 0.9, delay: Double = 0) -> some View {
        modifier(ScaleInModifier(scale: scale, delay: delay))
    }

    // MARK: - Staggered Animations

    /// Apply staggered animation based on index
    func staggeredAnimation(index: Int, baseDelay: Double = 0.05) -> some View {
        let delay = Double(index) * baseDelay
        return slideUpOnAppear(delay: delay)
    }
}

// MARK: - Animation Modifiers

private struct ConditionalAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

private struct FadeInModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var opacity: Double = 0

    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                if reduceMotion {
                    opacity = 1
                } else {
                    withAnimation(MicroTransitions.cardReveal.delay(delay)) {
                        opacity = 1
                    }
                }
            }
    }
}

private struct SlideUpModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let offset: CGFloat
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offset)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(MicroTransitions.cardReveal.delay(delay)) {
                        isVisible = true
                    }
                }
            }
    }
}

private struct ScaleInModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let scale: CGFloat
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : scale)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(MicroTransitions.cardReveal.delay(delay)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - Transition Extensions

extension AnyTransition {
    /// Slide and fade transition
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    /// Scale and fade transition
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }
}
