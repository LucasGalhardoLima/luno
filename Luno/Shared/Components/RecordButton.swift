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

    @State private var isPulsing = false

    // MARK: - Constants

    private let buttonSize: CGFloat = 84
    private let innerCircleSize: CGFloat = 68
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
                // Ambient glow
                if isRecording {
                    recordingGlow
                } else {
                    idleGlow
                }

                // Outer ring
                Circle()
                    .fill(LunoColors.brand600.opacity(0.10))
                    .overlay {
                        Circle()
                            .strokeBorder(
                                isRecording
                                    ? LunoColors.Recording.active.opacity(0.9)
                                    : LunoColors.brand500.opacity(0.85),
                                lineWidth: 3
                            )
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(LunoColors.lineSoft, lineWidth: 1)
                            .padding(1)
                    }
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: LunoColors.glowSoft.opacity(0.35), radius: 12, x: 0, y: 6)

                // Inner circle / Recording indicator
                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LunoColors.Recording.active)
                        .frame(width: recordingSquareSize, height: recordingSquareSize)
                } else {
                    Circle()
                        .fill(LunoColors.heroGradient)
                        .frame(width: innerCircleSize, height: innerCircleSize)
                        .overlay {
                            Circle()
                                .strokeBorder(LunoColors.text2.opacity(0.26), lineWidth: 1)
                        }

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
            isPulsing = newValue
        }
    }

    // MARK: - Idle Glow

    private var idleGlow: some View {
        Circle()
            .fill(LunoColors.glowSoft)
            .frame(width: 96, height: 96)
            .blur(radius: 16)
            .opacity(0.2)
    }

    // MARK: - Recording Glow

    @ViewBuilder
    private var recordingGlow: some View {
        if reduceMotion {
            Circle()
                .fill(LunoColors.Recording.glow)
                .frame(width: buttonSize * 1.5, height: buttonSize * 1.5)
                .opacity(0.35)
        } else {
            PhaseAnimator([false, true], trigger: isPulsing) { phase in
                Circle()
                    .fill(LunoColors.Recording.glow)
                    .frame(width: buttonSize * 1.5, height: buttonSize * 1.5)
                    .scaleEffect(phase ? 1.12 : 1.0)
                    .opacity(phase ? 0.45 : 0.25)
            } animation: { _ in
                .easeInOut(duration: 1.0)
            }
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
