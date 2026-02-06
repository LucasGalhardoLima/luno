import SwiftUI

// MARK: - Luno Colors

// Color palette for the Luno app - Lunar theme inspired by "lumen" (light)
// Based on Estrategia.md design specifications

enum LunoColors {
    // MARK: - Brand Colors (Luna Blue Palette)

    /// Luna Blue 600 - Primary CTAs, voice button
    static let lunaBlue600 = Color(hex: "3B82F6")

    /// Luna Blue 500 - Hover states, gradients
    static let lunaBlue500 = Color(hex: "60A5FA")

    /// Moonlight 400 - Accents, subtle highlights
    static let moonlight400 = Color(hex: "A5B4FC")

    /// Primary color (alias for lunaBlue600)
    static let primary = lunaBlue600

    /// Secondary color
    static let secondary = lunaBlue500

    /// Accent color
    static let accent = moonlight400

    // MARK: - Background Colors

    /// Dark mode background (deep night sky)
    static let slate950 = Color(hex: "020617")

    /// Dark mode card background
    static let slate900 = Color(hex: "0F172A")

    /// Light mode background
    static let slate50 = Color(hex: "F8FAFC")

    /// Adaptive background
    static var background: Color {
        Color.adaptive(light: slate50, dark: slate950)
    }

    /// Adaptive card background
    static var cardBackground: Color {
        Color.adaptive(light: .white, dark: slate900)
    }

    // MARK: - Text Colors

    /// Slate colors for text
    static let slate400 = Color(hex: "94A3B8")
    static let slate600 = Color(hex: "475569")

    /// Primary text - adaptive
    static var textPrimary: Color {
        Color.adaptive(light: slate900, dark: slate50)
    }

    /// Secondary text - adaptive
    static var textSecondary: Color {
        Color.adaptive(light: slate600, dark: slate400)
    }

    // MARK: - PARA Category Colors

    enum PARA {
        /// Projects - Active, deadline-driven (Luna Blue - action oriented)
        static let project = lunaBlue600

        /// Areas - Ongoing responsibilities (Emerald - growth, maintenance)
        static let area = Color(hex: "10B981") // Emerald 500

        /// Resources - Reference materials (Moonlight - knowledge)
        static let resource = moonlight400

        /// Archive - Completed/inactive (Slate - dormant)
        static let archive = slate400

        /// Uncategorized - Pending categorization (Amber - needs attention)
        static let uncategorized = Color(hex: "F59E0B") // Amber 500

        /// Get color for a category
        static func color(for category: String) -> Color {
            switch category.lowercased() {
            case "project", "projects":
                project
            case "area", "areas":
                area
            case "resource", "resources":
                resource
            case "archive":
                archive
            default:
                uncategorized
            }
        }
    }

    // MARK: - State Colors

    enum State {
        static let success = Color(hex: "10B981") // Emerald 500
        static let warning = Color(hex: "F59E0B") // Amber 500
        static let error = Color(hex: "F43F5E") // Rose 500
        static let info = lunaBlue600
    }

    // MARK: - Recording Colors

    enum Recording {
        static let active = Color(hex: "F43F5E") // Rose 500
        static let idle = slate400
        static let waveform = lunaBlue500
        static let glow = lunaBlue600.opacity(0.3)
    }

    // MARK: - Gradients

    /// Hero gradient (Luna Blue to Purple)
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Lunar gradient (softer)
    static let lunarGradient = LinearGradient(
        colors: [Color(hex: "60A5FA"), Color(hex: "A5B4FC")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Voice button gradient
    static let voiceButtonGradient = LinearGradient(
        colors: [lunaBlue600, lunaBlue500],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Returns an adaptive color that works in both light and dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
