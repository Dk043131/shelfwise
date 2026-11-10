import SwiftUI

public struct BookCoverView: View {
    let book: Book
    var width: CGFloat = 84
    var height: CGFloat = 118
    var cornerRadius: CGFloat = 8
    
    @ObservedObject private var dataManager = DataManager.shared
    
    public init(book: Book, width: CGFloat = 84, height: CGFloat = 118, cornerRadius: CGFloat = 8) {
        self.book = book
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        ZStack {
            // Priority 1: User custom cover
            if let customName = book.customCoverFileName,
               let uiImage = dataManager.loadImage(fileName: customName) {
                #if canImport(UIKit)
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
                #endif
            }
            // Priority 2: Real book thumbnail from Assets
            else if let assetName = book.assetCoverName,
                    UIImage(named: assetName) != nil {
                #if canImport(UIKit)
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
                #endif
            }
            // Priority 3: Procedural fallback
            else {
                proceduralCover
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            // Left Spine Shadow Effect for 3D Book Depth
            HStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.40),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: max(4, width * 0.08))
                Spacer()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 8, x: 2, y: 4)
    }
    
    private var proceduralCover: some View {
        let colors = book.gradientHexes.map { Color(hex: $0) }
        let primaryColor = colors.first ?? Color(red: 0.12, green: 0.15, blue: 0.28)
        let secondaryColor = colors.last ?? Color(red: 0.25, green: 0.20, blue: 0.45)
        
        return ZStack {
            LinearGradient(
                colors: [primaryColor, secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle psychological background geometry
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: book.dominantTopics.first?.systemIcon ?? "brain.head.profile")
                        .font(.system(size: width * 0.35))
                        .foregroundColor(.white.opacity(0.12))
                        .offset(x: 10, y: -10)
                }
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(book.title)
                    .font(.system(size: max(9, width * 0.12), weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Spacer()
                
                Text(book.author)
                    .font(.system(size: max(7, width * 0.085), weight: .medium))
                    .foregroundColor(Color.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(width > 100 ? 12 : 8)
            .padding(.leading, max(2, width * 0.04)) // offset slightly for spine
        }
    }
}
