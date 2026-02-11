import SwiftUI

// MARK: - Luno Colors

// Landing-aligned color palette for the Lunar Minimal system.
// Tokens mirror landing/src/styles/global.css and remain adaptive for iOS.

enum LunoColors {
    // MARK: - Core Palette (Landing tokens)

    static let bg0 = Color.adaptive(light: Color(hex: "E0EAFF"), dark: Color(hex: "020617"))
    static let bg1 = Color.adaptive(light: Color(hex: "CDDAFF"), dark: Color(hex: "0F172A"))
    static let bg2 = Color.adaptive(light: Color(hex: "B4C8FF"), dark: Color(hex: "172554"))

    static let surface1 = Color.adaptive(
        light: Color.rgba(255, 255, 255, 0.88),
        dark: Color.rgba(15, 23, 42, 0.72)
    )
    static let surface2 = Color.adaptive(
        light: Color.rgba(255, 255, 255, 0.95),
        dark: Color.rgba(15, 23, 42, 0.92)
    )

    static let brand600 = Color.adaptive(light: Color(hex: "2563EB"), dark: Color(hex: "3B82F6"))
    static let brand500 = Color.adaptive(light: Color(hex: "3B82F6"), dark: Color(hex: "60A5FA"))
    static let moon400 = Color.adaptive(light: Color(hex: "4F46E5"), dark: Color(hex: "A5B4FC"))

    static let lineSoft = Color.adaptive(
        light: Color.rgba(37, 99, 235, 0.30),
        dark: Color.rgba(165, 180, 252, 0.24)
    )
    static let glowSoft = Color.adaptive(
        light: Color.rgba(59, 130, 246, 0.26),
        dark: Color.rgba(96, 165, 250, 0.24)
    )
    static let glowStrong = Color.adaptive(
        light: Color.rgba(59, 130, 246, 0.34),
        dark: Color.rgba(96, 165, 250, 0.44)
    )

    static let shadowColor = Color.adaptive(
        light: Color.rgba(37, 99, 235, 0.15),
        dark: Color.rgba(0, 0, 0, 0.30)
    )

    static let text0 = Color.adaptive(light: Color(hex: "0F172A"), dark: Color(hex: "EFF6FF"))
    static let text1 = Color.adaptive(light: Color(hex: "334155"), dark: Color(hex: "9FB4D4"))
    static let text2 = Color.adaptive(light: Color(hex: "1E293B"), dark: Color(hex: "DBEAFE"))

    // MARK: - App aliases (kept for compatibility)

    static let lunaBlue600 = brand600
    static let lunaBlue500 = brand500
    static let moonlight400 = moon400
    static let primary = brand600
    static let secondary = brand500
    static let accent = moon400

    static var background: Color { bg0 }
    static var cardBackground: Color { surface2 }
    static var textPrimary: Color { text0 }
    static var textSecondary: Color { text1 }

    static let slate950 = Color(hex: "020617")
    static let slate900 = Color(hex: "0F172A")
    static let slate50 = Color(hex: "F8FAFC")
    static let slate400 = Color(hex: "94A3B8")
    static let slate600 = Color(hex: "475569")

    static let appGradient = LinearGradient(
        colors: [bg0, bg1, bg2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - PARA Category Colors

    enum PARA {
        static let project = Color.adaptive(light: Color(hex: "0284C7"), dark: Color(hex: "7DD3FC"))
        static let area = Color.adaptive(light: Color(hex: "4338CA"), dark: Color(hex: "A5B4FC"))
        static let resource = Color.adaptive(light: Color(hex: "7C3AED"), dark: Color(hex: "C4B5FD"))
        static let archive = Color.adaptive(light: Color(hex: "1D4ED8"), dark: Color(hex: "93C5FD"))
        static let uncategorized = Color.adaptive(light: Color(hex: "EA580C"), dark: Color(hex: "F59E0B"))

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
        static let success = Color.adaptive(light: Color(hex: "059669"), dark: Color(hex: "34D399"))
        static let warning = Color.adaptive(light: Color(hex: "D97706"), dark: Color(hex: "FBBF24"))
        static let error = Color.adaptive(light: Color(hex: "E11D48"), dark: Color(hex: "FB7185"))
        static let info = brand600
    }

    // MARK: - Recording Colors

    enum Recording {
        static let active = Color.adaptive(light: Color(hex: "E11D48"), dark: Color(hex: "FB7185"))
        static let idle = text1
        static let waveform = brand500
        static let glow = glowSoft
    }

    // MARK: - Gradients

    static let heroGradient = LinearGradient(
        colors: [brand600, moon400],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let lunarGradient = LinearGradient(
        colors: [brand500, moon400],
        startPoint: .top,
        endPoint: .bottom
    )

    static let voiceButtonGradient = LinearGradient(
        colors: [brand600, brand500],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }

    static func rgba(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) -> Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
    }
}
