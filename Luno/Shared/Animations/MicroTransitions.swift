import SwiftUI

// MARK: - Micro Transitions

// Shared animation configurations for consistent micro-interactions
// Constitution: Respect Reduce Motion accessibility setting

enum MicroTransitions {
    // MARK: - Spring Animations

    /// Quick, snappy spring for button taps
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)

    /// Smooth spring for card reveals
    static let cardReveal = Animation.spring(response: 0.4, dampingFraction: 0.75)

    /// Gentle spring for modal presentations
    static let modalPresent = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Bouncy spring for playful interactions
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.5)

    /// Smooth spring for general UI transitions
    static let smooth = Animation.spring(response: 0.55, dampingFraction: 0.825)

    // MARK: - Timing Animations

    /// Quick ease for instant feedback
    static let instant = Animation.easeOut(duration: 0.1)

    /// Fast ease for micro-interactions
    static let fast = Animation.easeInOut(duration: 0.2)

    /// Normal ease for standard transitions
    static let normal = Animation.easeInOut(duration: 0.3)

    /// Slow ease for deliberate animations
    static let slow = Animation.easeInOut(duration: 0.5)

    // MARK: - Scale Effects

    enum Scale {
        static let pressed: CGFloat = 0.95
        static let highlighted: CGFloat = 1.02
        static let normal: CGFloat = 1.0
        static let enlarged: CGFloat = 1.1
    }

    // MARK: - Opacity Effects

    enum Opacity {
        static let pressed: Double = 0.8
        static let disabled: Double = 0.5
        static let normal: Double = 1.0
        static let subtle: Double = 0.6
    }
}

// MARK: - Button Styles

/// Scale button style with micro-transition
struct ScaleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? MicroTransitions.Scale.pressed : MicroTransitions.Scale.normal)
            .opacity(configuration.isPressed ? MicroTransitions.Opacity.pressed : MicroTransitions.Opacity.normal)
            .animation(
                reduceMotion ? nil : MicroTransitions.buttonPress,
                value: configuration.isPressed
            )
    }
}

/// Bounce button style for playful interactions
struct BounceButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? MicroTransitions.Scale.pressed : MicroTransitions.Scale.normal)
            .animation(
                reduceMotion ? nil : MicroTransitions.bouncy,
                value: configuration.isPressed
            )
    }
}

// MARK: - View Modifiers

/// Animated appearance modifier
struct AnimatedAppearance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
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

/// Press feedback modifier
struct PressModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? MicroTransitions.Scale.pressed : MicroTransitions.Scale.normal)
            .animation(
                reduceMotion ? nil : MicroTransitions.buttonPress,
                value: isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply scale button style
    func scaleButtonStyle() -> some View {
        buttonStyle(ScaleButtonStyle())
    }

    /// Apply bounce button style
    func bounceButtonStyle() -> some View {
        buttonStyle(BounceButtonStyle())
    }

    /// Apply animated appearance with optional delay
    func animatedAppearance(delay: Double = 0) -> some View {
        modifier(AnimatedAppearance(delay: delay))
    }

    /// Apply press feedback
    func pressEffect() -> some View {
        modifier(PressModifier())
    }

    /// Animate with accessibility consideration
    func animateWithMotionPreference(
        _ animation: Animation?,
        value: some Equatable
    ) -> some View {
        modifier(MotionAwareAnimationModifier(animation: animation, value: value))
    }
}

/// Motion-aware animation modifier
struct MotionAwareAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
