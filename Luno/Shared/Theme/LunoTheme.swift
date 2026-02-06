import SwiftUI

// MARK: - Luno Theme

// Central theme configuration for the Luno app
// Constitution: Follow Apple Human Interface Guidelines

enum LunoTheme {
    // MARK: - Spacing

    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let card: CGFloat = 16
        static let button: CGFloat = 12
    }

    // MARK: - Shadows

    enum Shadow {
        static let cardRadius: CGFloat = 8
        static let cardY: CGFloat = 4
        static let cardOpacity: Double = 0.1

        static let elevatedRadius: CGFloat = 16
        static let elevatedY: CGFloat = 8
        static let elevatedOpacity: Double = 0.15

        static let subtleRadius: CGFloat = 4
        static let subtleY: CGFloat = 2
        static let subtleOpacity: Double = 0.05
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle: Font = .largeTitle
        static let title: Font = .title
        static let title2: Font = .title2
        static let title3: Font = .title3
        static let headline: Font = .headline
        static let body: Font = .body
        static let callout: Font = .callout
        static let subheadline: Font = .subheadline
        static let footnote: Font = .footnote
        static let caption: Font = .caption
        static let caption2: Font = .caption2
    }

    // MARK: - Touch Targets

    enum TouchTarget {
        /// Minimum touch target size per Apple HIG (44x44pt)
        static let minimum: CGFloat = 44
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }

    // MARK: - Animation Durations

    enum Duration {
        static let instant: Double = 0.1
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let deliberate: Double = 0.8
    }
}

// MARK: - View Extensions

extension View {
    /// Apply card shadow style
    func cardShadow() -> some View {
        shadow(
            color: .black.opacity(LunoTheme.Shadow.cardOpacity),
            radius: LunoTheme.Shadow.cardRadius,
            x: 0,
            y: LunoTheme.Shadow.cardY
        )
    }

    /// Apply elevated shadow style
    func elevatedShadow() -> some View {
        shadow(
            color: .black.opacity(LunoTheme.Shadow.elevatedOpacity),
            radius: LunoTheme.Shadow.elevatedRadius,
            x: 0,
            y: LunoTheme.Shadow.elevatedY
        )
    }

    /// Apply subtle shadow style
    func subtleShadow() -> some View {
        shadow(
            color: .black.opacity(LunoTheme.Shadow.subtleOpacity),
            radius: LunoTheme.Shadow.subtleRadius,
            x: 0,
            y: LunoTheme.Shadow.subtleY
        )
    }
}
