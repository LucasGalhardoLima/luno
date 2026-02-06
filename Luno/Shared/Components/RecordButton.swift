import SwiftUI

// MARK: - Record Button

// Animated voice recording button with Luna Blue design
// Constitution: Micro-transitions with accessibility support

struct RecordButton: View {
    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isRecording: Bool
    let isDisabled: Bool
    let action: () -> Void

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0

    // MARK: - Constants

    private let buttonSize: CGFloat = 72
    private let innerCircleSize: CGFloat = 56
    private let recordingSquareSize: CGFloat = 24

    // MARK: - Initialization

    init(
        isRecording: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.isRecording = isRecording
        self.isDisabled = isDisabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow effect when recording
                if isRecording {
                    Circle()
                        .fill(LunoColors.Recording.glow)
                        .frame(width: buttonSize * 1.5, height: buttonSize * 1.5)
                        .scaleEffect(pulseScale)
                        .opacity(glowOpacity)
                }

                // Outer ring
                Circle()
                    .stroke(
                        isRecording
                            ? LunoColors.Recording.active
                            : LunoColors.primary,
                        lineWidth: 4
                    )
                    .frame(width: buttonSize, height: buttonSize)

                // Inner circle / Recording indicator
                if isRecording {
                    // Recording: show rounded square
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LunoColors.Recording.active)
                        .frame(width: recordingSquareSize, height: recordingSquareSize)
                } else {
                    // Idle: show filled circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LunoColors.lunaBlue600, LunoColors.lunaBlue500],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: innerCircleSize, height: innerCircleSize)

                    // Mic icon
                    Image(systemName: "mic.fill")
                        .font(LunoTheme.Typography.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(RecordButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? MicroTransitions.Opacity.disabled : MicroTransitions.Opacity.normal)
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint(isRecording ? "Double tap to stop" : "Double tap to start voice recording")
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
    }

    // MARK: - Animations

    private func startPulseAnimation() {
        guard !reduceMotion else {
            glowOpacity = 0.5
            return
        }

        withAnimation(.easeIn(duration: 0.2)) {
            glowOpacity = 0.5
        }

        withAnimation(
            .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.15
        }
    }

    private func stopPulseAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            pulseScale = 1.0
            glowOpacity = 0.0
        }
    }
}

// MARK: - Record Button Style

private struct RecordButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                reduceMotion ? nil : MicroTransitions.buttonPress,
                value: configuration.isPressed
            )
    }
}

// MARK: - Preview

#Preview("Record Button States") {
    VStack(spacing: LunoTheme.Spacing.xl) {
        // Idle state
        VStack {
            Text("Idle")
                .font(LunoTheme.Typography.caption)
            RecordButton(isRecording: false) {}
        }

        // Recording state
        VStack {
            Text("Recording")
                .font(LunoTheme.Typography.caption)
            RecordButton(isRecording: true) {}
        }

        // Disabled state
        VStack {
            Text("Disabled")
                .font(LunoTheme.Typography.caption)
            RecordButton(isRecording: false, isDisabled: true) {}
        }
    }
    .padding()
    .background(LunoColors.background)
}
