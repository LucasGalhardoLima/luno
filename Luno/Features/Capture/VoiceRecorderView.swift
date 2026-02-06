import SwiftUI

// MARK: - Voice Recorder View

// Waveform visualization for voice recording
// Constitution: Provide visual feedback with accessibility support

struct VoiceRecorderView: View {
    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isRecording: Bool
    let audioLevel: CGFloat

    @State private var waveformPhase: CGFloat = 0

    // MARK: - Constants

    private let barCount = 5
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 6
    private let minBarHeight: CGFloat = 8
    private let maxBarHeight: CGFloat = 32

    // MARK: - Body

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0 ..< barCount, id: \.self) { index in
                waveformBar(at: index)
            }
        }
        .frame(height: maxBarHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRecording ? "Recording audio" : "Audio recorder idle")
        .accessibilityValue(isRecording ? "Audio level: \(Int(audioLevel * 100)) percent" : "")
        .onAppear {
            if isRecording, !reduceMotion {
                startAnimation()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue, !reduceMotion {
                startAnimation()
            }
        }
    }

    // MARK: - Waveform Bar

    @ViewBuilder
    private func waveformBar(at index: Int) -> some View {
        let height = calculateBarHeight(at: index)

        RoundedRectangle(cornerRadius: barWidth / 2)
            .fill(isRecording ? LunoColors.Recording.waveform : LunoColors.Recording.idle)
            .frame(width: barWidth, height: height)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.15),
                value: height
            )
    }

    // MARK: - Height Calculation

    private func calculateBarHeight(at index: Int) -> CGFloat {
        guard isRecording else {
            return minBarHeight
        }

        // Create wave pattern based on index and phase
        let normalizedIndex = CGFloat(index) / CGFloat(barCount - 1)
        let phaseOffset = sin((normalizedIndex + waveformPhase) * .pi * 2)

        // Combine with audio level
        let levelInfluence = audioLevel * 0.7
        let waveInfluence = (phaseOffset + 1) / 2 * 0.3

        let normalizedHeight = levelInfluence + waveInfluence
        return minBarHeight + (maxBarHeight - minBarHeight) * normalizedHeight
    }

    // MARK: - Animation

    private func startAnimation() {
        guard !reduceMotion else { return }

        withAnimation(
            .linear(duration: 1.0)
                .repeatForever(autoreverses: false)
        ) {
            waveformPhase = 1.0
        }
    }
}

// MARK: - Waveform Display

/// Larger waveform display for recording feedback
struct WaveformDisplay: View {
    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isRecording: Bool

    @State private var levels: [CGFloat] = Array(repeating: 0.1, count: 20)
    @State private var animationTimer: Timer?

    // MARK: - Constants

    private let barCount = 20
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 3
    private let minHeight: CGFloat = 4
    private let maxHeight: CGFloat = 48

    // MARK: - Body

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0 ..< barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(
                        isRecording
                            ? LunoColors.Recording.waveform.opacity(0.8)
                            : LunoColors.Recording.idle.opacity(0.5)
                    )
                    .frame(
                        width: barWidth,
                        height: minHeight + (maxHeight - minHeight) * levels[index]
                    )
            }
        }
        .frame(height: maxHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRecording ? "Recording waveform active" : "Recording waveform idle")
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startSimulation()
            } else {
                stopSimulation()
            }
        }
        .onDisappear {
            stopSimulation()
        }
    }

    // MARK: - Simulation

    private func startSimulation() {
        guard !reduceMotion else {
            levels = Array(repeating: 0.3, count: barCount)
            return
        }

        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                levels = levels.map { _ in
                    CGFloat.random(in: 0.1 ... 0.9)
                }
            }
        }
    }

    private func stopSimulation() {
        animationTimer?.invalidate()
        animationTimer = nil

        withAnimation(.easeOut(duration: 0.3)) {
            levels = Array(repeating: 0.1, count: barCount)
        }
    }
}

// MARK: - Preview

#Preview("Voice Recorder View") {
    VStack(spacing: LunoTheme.Spacing.xl) {
        // Idle
        VStack {
            Text("Idle")
                .font(LunoTheme.Typography.caption)
            VoiceRecorderView(isRecording: false, audioLevel: 0)
        }

        // Recording - low level
        VStack {
            Text("Recording - Low")
                .font(LunoTheme.Typography.caption)
            VoiceRecorderView(isRecording: true, audioLevel: 0.2)
        }

        // Recording - high level
        VStack {
            Text("Recording - High")
                .font(LunoTheme.Typography.caption)
            VoiceRecorderView(isRecording: true, audioLevel: 0.8)
        }

        Divider()

        // Full waveform display
        VStack {
            Text("Waveform Display")
                .font(LunoTheme.Typography.caption)
            WaveformDisplay(isRecording: true)
        }
    }
    .padding()
    .background(LunoColors.background)
}
