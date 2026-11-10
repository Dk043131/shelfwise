import SwiftUI

public enum NocturneTheme {
    // Primary Backgrounds
    public static let bgVoid = Color(red: 0.04, green: 0.05, blue: 0.08) // Deep Obsidian Void
    public static let bgSurface = Color(red: 0.08, green: 0.10, blue: 0.15) // Dark Slate Card
    public static let bgSurfaceElevated = Color(red: 0.12, green: 0.14, blue: 0.22) // Elevated Surface
    public static let bgCardBorder = Color(white: 1.0, opacity: 0.10)
    
    // Brand Accents
    public static let purplePrimary = Color(red: 0.55, green: 0.36, blue: 0.97) // #8B5CF6
    public static let purpleBright = Color(red: 0.65, green: 0.45, blue: 0.99)
    public static let purpleDeep = Color(red: 0.38, green: 0.20, blue: 0.85)
    
    // Gradients
    public static let liquidPurpleGradient = LinearGradient(
        colors: [purpleBright, purpleDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.07, blue: 0.12),
            Color(red: 0.04, green: 0.04, blue: 0.07)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View Modifiers for Liquid Glass Cards
public struct LiquidCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderColor: Color = NocturneTheme.bgCardBorder
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(NocturneTheme.bgSurface.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.04),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 12, x: 0, y: 6)
            )
    }
}

public struct LiquidGlassPillModifier: ViewModifier {
    var isSelected: Bool
    var tintColor: Color
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? tintColor.opacity(0.25) : Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? tintColor.opacity(0.6) : Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : Color(white: 0.75))
    }
}

public extension View {
    func liquidCard(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(LiquidCardModifier(cornerRadius: cornerRadius))
    }
    
    func liquidGlassPill(isSelected: Bool, tintColor: Color = NocturneTheme.purplePrimary) -> some View {
        self.modifier(LiquidGlassPillModifier(isSelected: isSelected, tintColor: tintColor))
    }
}

// Color Hex Extension
public extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
