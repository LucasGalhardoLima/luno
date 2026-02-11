import SwiftUI
import UIKit

// MARK: - Luno Theme

// Central theme configuration for the Luno app
// Lunar Minimal + Liquid Glass style system.

enum LunoTheme {
    // MARK: - Spacing

    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 7
        static let sm: CGFloat = 11
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let card: CGFloat = 18
        static let button: CGFloat = 14
        static let chip: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadow {
        static let cardRadius: CGFloat = 18
        static let cardY: CGFloat = 8
        static let cardOpacity: Double = 0.18

        static let elevatedRadius: CGFloat = 28
        static let elevatedY: CGFloat = 14
        static let elevatedOpacity: Double = 0.22

        static let subtleRadius: CGFloat = 10
        static let subtleY: CGFloat = 2
        static let subtleOpacity: Double = 0.10
    }

    // MARK: - Glass

    enum Glass {
        static let overlayOpacity: Double = 0.15
        static let strokeWidth: CGFloat = 1.5
        static let blurRadius: CGFloat = 18
    }

    // MARK: - Typography

    enum Typography {
        // Display (Syne + fallback)
        static let displayLg: Font = display(42, relativeTo: .largeTitle)
        static let displayMd: Font = display(34, relativeTo: .title)
        static let sectionTitle: Font = display(24, relativeTo: .title2)

        // Core UI typography
        static let largeTitle: Font = display(34, relativeTo: .largeTitle)
        static let title: Font = display(28, relativeTo: .title)
        static let title2: Font = display(22, relativeTo: .title2)
        static let title3: Font = .system(.title3, design: .rounded).weight(.semibold)
        static let headline: Font = .system(.headline, design: .rounded).weight(.semibold)
        static let body: Font = .body
        static let callout: Font = .callout
        static let subheadline: Font = .subheadline
        static let footnote: Font = .footnote
        static let caption: Font = .caption
        static let caption2: Font = .caption2

        private static func display(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
            // Prefer bundled Syne variable font for titles. Fall back to rounded system face.
            if UIFont(name: "Syne", size: size) != nil {
                return .custom("Syne", size: size, relativeTo: textStyle).weight(.semibold)
            }
            return .system(size: size, weight: .semibold, design: .rounded)
        }
    }

    // MARK: - Touch Targets

    enum TouchTarget {
        /// Minimum touch target size per Apple HIG (44x44pt)
        static let minimum: CGFloat = 44
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }

    // MARK: - Appearance Configuration

    static func configureFontAppearance() {
        let inlineSize: CGFloat = 17
        let largeSize: CGFloat = 34
        let syneInline = UIFont(name: "Syne", size: inlineSize) ?? .systemFont(ofSize: inlineSize, weight: .semibold)
        let syneLarge = UIFont(name: "Syne", size: largeSize) ?? .systemFont(ofSize: largeSize, weight: .bold)

        let inlineDescriptor = syneInline.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        let largeDescriptor = syneLarge.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
        ])

        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(descriptor: inlineDescriptor, size: inlineSize)
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(descriptor: largeDescriptor, size: largeSize)
        ]
    }

    // MARK: - Animation Durations

    enum Duration {
        static let instant: Double = 0.12
        static let fast: Double = 0.18
        static let normal: Double = 0.26
        static let slow: Double = 0.34
        static let deliberate: Double = 0.45
    }
}

// MARK: - View Extensions

extension View {
    func cardShadow() -> some View {
        shadow(
            color: LunoColors.shadowColor.opacity(LunoTheme.Shadow.cardOpacity),
            radius: LunoTheme.Shadow.cardRadius,
            x: 0,
            y: LunoTheme.Shadow.cardY
        )
    }

    func elevatedShadow() -> some View {
        shadow(
            color: LunoColors.shadowColor.opacity(LunoTheme.Shadow.elevatedOpacity),
            radius: LunoTheme.Shadow.elevatedRadius,
            x: 0,
            y: LunoTheme.Shadow.elevatedY
        )
    }

    func subtleShadow() -> some View {
        shadow(
            color: LunoColors.shadowColor.opacity(LunoTheme.Shadow.subtleOpacity),
            radius: LunoTheme.Shadow.subtleRadius,
            x: 0,
            y: LunoTheme.Shadow.subtleY
        )
    }
}
