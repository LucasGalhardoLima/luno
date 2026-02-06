import SwiftUI

// MARK: - Capture View

// Main voice and text note capture interface
// Constitution: Clean notebook-inspired design with micro-transitions

struct CaptureView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CaptureViewModel

    // MARK: - Initialization

    init(noteRepository: any NoteRepositoryProtocol) {
        _viewModel = State(initialValue: CaptureViewModel(noteRepository: noteRepository))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LunoColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Input mode toggle
                    inputModeToggle
                        .padding(.horizontal, LunoTheme.Spacing.md)
                        .padding(.top, LunoTheme.Spacing.sm)

                    // Main content area
                    contentArea
                        .padding(.horizontal, LunoTheme.Spacing.md)

                    Spacer()

                    // Bottom controls
                    bottomControls
                        .padding(.horizontal, LunoTheme.Spacing.md)
                        .padding(.bottom, LunoTheme.Spacing.lg)
                }
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.checkAuthorization()
            }
            .alert(
                "Error",
                isPresented: .init(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                ),
                presenting: viewModel.error
            ) { _ in
                Button("OK") { viewModel.clearError() }
            } message: { error in
                Text(error.localizedDescription)
            }
            .sheet(
                isPresented: $viewModel.showCategorizationSheet
            ) {
                if let note = viewModel.savedNote {
                    CategorizationSheet(
                        note: note,
                        categorizationResult: viewModel.categorizationResult,
                        onAccept: { category in
                            Task {
                                await viewModel.applyCategory(category, to: note)
                            }
                        },
                        onSkip: {
                            // Leave as uncategorized
                        }
                    )
                }
            }
        }
    }

    // MARK: - Input Mode Toggle

    private var inputModeToggle: some View {
        HStack(spacing: LunoTheme.Spacing.xs) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(MicroTransitions.fast) {
                        if viewModel.inputMode != mode {
                            viewModel.toggleInputMode()
                        }
                    }
                } label: {
                    HStack(spacing: LunoTheme.Spacing.xxs) {
                        Image(systemName: mode.iconName)
                            .font(LunoTheme.Typography.footnote)

                        Text(mode.label)
                            .font(LunoTheme.Typography.footnote)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, LunoTheme.Spacing.sm)
                    .padding(.vertical, LunoTheme.Spacing.xs)
                    .background(
                        viewModel.inputMode == mode
                            ? LunoColors.primary.opacity(0.15)
                            : Color.clear
                    )
                    .foregroundStyle(
                        viewModel.inputMode == mode
                            ? LunoColors.primary
                            : LunoColors.textSecondary
                    )
                    .clipShape(Capsule())
                }
                .disabled(viewModel.captureState == .recording)
                .accessibilityLabel("\(mode.label) input mode")
                .accessibilityAddTraits(viewModel.inputMode == mode ? .isSelected : [])
            }

            Spacer()
        }
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.inputMode {
        case .voice:
            voiceContentArea
        case .text:
            textContentArea
        }
    }

    private var voiceContentArea: some View {
        VStack(spacing: LunoTheme.Spacing.lg) {
            Spacer()

            // Transcription display or placeholder
            if viewModel.transcription.isEmpty, viewModel.captureState != .recording {
                emptyStateView
            } else {
                transcriptionView
            }

            // Waveform when recording
            if viewModel.captureState == .recording {
                WaveformDisplay(isRecording: true)
                    .padding(.vertical, LunoTheme.Spacing.md)
            }

            Spacer()
        }
    }

    private var textContentArea: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            // Text editor
            TextEditor(text: $viewModel.transcription)
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textPrimary)
                .scrollContentBackground(.hidden)
                .background(LunoColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.md))
                .overlay {
                    if viewModel.transcription.isEmpty {
                        Text("Start typing your note...")
                            .font(LunoTheme.Typography.body)
                            .foregroundStyle(LunoColors.textSecondary)
                            .allowsHitTesting(false)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(LunoTheme.Spacing.sm)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, LunoTheme.Spacing.md)
                .accessibilityLabel("Note text input")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            Image(systemName: "mic.fill")
                .font(LunoTheme.Typography.largeTitle)
                .foregroundStyle(LunoColors.textSecondary.opacity(0.5))

            Text("Tap to start recording")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textSecondary)

            if !viewModel.isAuthorized {
                Button("Enable Microphone") {
                    Task {
                        await viewModel.requestAuthorization()
                    }
                }
                .font(LunoTheme.Typography.callout)
                .foregroundStyle(LunoColors.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var transcriptionView: some View {
        ScrollView {
            Text(viewModel.transcription)
                .font(LunoTheme.Typography.title3)
                .foregroundStyle(LunoColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(LunoTheme.Spacing.md)
        }
        .background(LunoColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.md))
        .cardShadow()
    }

    // MARK: - Bottom Controls

    @ViewBuilder
    private var bottomControls: some View {
        switch viewModel.captureState {
        case .idle:
            idleControls
        case .recording:
            recordingControls
        case .reviewing:
            reviewingControls
        case .saving:
            savingControls
        }
    }

    private var idleControls: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            if viewModel.inputMode == .voice {
                RecordButton(
                    isRecording: false,
                    isDisabled: !viewModel.isAuthorized
                ) {
                    Task {
                        await viewModel.startRecording()
                    }
                }
            } else {
                // Save button for text mode
                Button {
                    Task {
                        await viewModel.saveNote()
                    }
                } label: {
                    Text("Save Note")
                        .font(LunoTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LunoTheme.Spacing.md)
                        .background(LunoColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
                }
                .disabled(viewModel.transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(
                    viewModel.transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? MicroTransitions.Opacity.disabled
                        : MicroTransitions.Opacity.normal
                )
                .accessibilityLabel("Save note")
                .accessibilityHint("Double tap to save the typed note")
            }
        }
    }

    private var recordingControls: some View {
        VStack(spacing: LunoTheme.Spacing.md) {
            Text("Listening...")
                .font(LunoTheme.Typography.caption)
                .foregroundStyle(LunoColors.Recording.active)

            RecordButton(isRecording: true) {
                Task {
                    await viewModel.stopRecording()
                }
            }
        }
    }

    private var reviewingControls: some View {
        HStack(spacing: LunoTheme.Spacing.md) {
            // Discard button
            Button {
                viewModel.discardNote()
            } label: {
                Text("Discard")
                    .font(LunoTheme.Typography.headline)
                    .foregroundStyle(LunoColors.State.error)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LunoTheme.Spacing.md)
                    .background(LunoColors.State.error.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
            }
            .accessibilityLabel("Discard note")
            .accessibilityHint("Double tap to discard the recorded note")

            // Save button
            Button {
                Task {
                    await viewModel.saveNote()
                }
            } label: {
                Text("Save")
                    .font(LunoTheme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LunoTheme.Spacing.md)
                    .background(LunoColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: LunoTheme.CornerRadius.button))
            }
            .accessibilityLabel("Save note")
            .accessibilityHint("Double tap to save the recorded note")
        }
    }

    private var savingControls: some View {
        HStack(spacing: LunoTheme.Spacing.sm) {
            ProgressView()
                .tint(LunoColors.primary)

            Text("Saving...")
                .font(LunoTheme.Typography.body)
                .foregroundStyle(LunoColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Saving note")
    }
}

// MARK: - Preview

#Preview("Capture View") {
    CaptureView(noteRepository: MockNoteRepository())
}
