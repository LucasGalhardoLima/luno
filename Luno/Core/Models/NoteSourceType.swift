import Foundation

// MARK: - Note Source Type

// Indicates how a note was created
// Constitution: Keep models simple and focused

enum NoteSourceType: String, Codable, CaseIterable, Sendable {
    /// Note created via voice recording and transcription
    case voice

    /// Note created via text input
    case text
}
