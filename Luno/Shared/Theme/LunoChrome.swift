import SwiftUI

// MARK: - Luno Chrome

struct LunoBackgroundView: View {
    var body: some View {
        ZStack {
            LunoColors.appGradient

            Circle()
                .fill(LunoColors.glowSoft)
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: -80, y: -100)

            Circle()
                .fill(LunoColors.moon400.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 120, y: 200)

            Circle()
                .fill(LunoColors.brand500.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 50)
                .offset(x: 20, y: 500)
        }
        .ignoresSafeArea()
    }
}

private struct LunoGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fill: Color

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill.opacity(0.3))
                )
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .opacity(LunoTheme.Glass.overlayOpacity)
                        )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(LunoColors.lineSoft, lineWidth: LunoTheme.Glass.strokeWidth)
                }
        }
    }
}

private struct LunoTabChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(LunoColors.surface2, for: .tabBar)
        }
    }
}

private struct LunoNavChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(LunoColors.surface2, for: .navigationBar)
        }
    }
}

extension View {
    func lunoGlassSurface(
        cornerRadius: CGFloat = LunoTheme.CornerRadius.card,
        fill: Color = LunoColors.surface1
    ) -> some View {
        modifier(LunoGlassSurfaceModifier(cornerRadius: cornerRadius, fill: fill))
    }

    func lunoGlassStroke(cornerRadius: CGFloat = LunoTheme.CornerRadius.card) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(LunoColors.lineSoft, lineWidth: LunoTheme.Glass.strokeWidth)
        }
    }

    func lunoTabChrome() -> some View {
        modifier(LunoTabChromeModifier())
    }

    func lunoNavChrome() -> some View {
        modifier(LunoNavChromeModifier())
    }
}
