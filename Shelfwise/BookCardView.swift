import SwiftUI

public struct BookCardView: View {
    let book: Book
    var onOpenDetail: () -> Void
    var onLogPages: () -> Void
    var onTopicTap: ((PsychologyTopic) -> Void)?
    
    @ObservedObject private var dataManager = DataManager.shared
    
    public init(
        book: Book,
        onLogPages: @escaping () -> Void,
        onOpenDetail: @escaping () -> Void,
        onTopicTap: ((PsychologyTopic) -> Void)? = nil
    ) {
        self.book = book
        self.onLogPages = onLogPages
        self.onOpenDetail = onOpenDetail
        self.onTopicTap = onTopicTap
    }
    
    private var hasLoggedToday: Bool {
        dataManager.hasLoggedToday(for: book.id)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Main Top Row: Book Cover + Meta Info
            HStack(alignment: .top, spacing: 14) {
                // Book Cover (Shows official thumbnail)
                BookCoverView(book: book, width: 86, height: 122, cornerRadius: 8)
                
                // Book Metadata
                VStack(alignment: .leading, spacing: 6) {
                    // Status Badge
                    HStack {
                        statusBadge(for: book.status)
                        Spacer()
                        Text("Lvl \(book.levelNumber)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(NocturneTheme.purpleBright)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.2)))
                    }
                    
                    // Title
                    Text(book.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Author
                    Text(book.author)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.65))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Dominant Topic or AI Custom Topics Pill
                    if let primaryTopic = book.dominantTopics.first {
                        Button(action: { onTopicTap?(primaryTopic) }) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(primaryTopic.accentColor)
                                    .frame(width: 7, height: 7)
                                Text(primaryTopic.shortName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(primaryTopic.accentColor)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(primaryTopic.accentColor.opacity(0.18)))
                            .overlay(Capsule().stroke(primaryTopic.accentColor.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    } else if let customTopic = book.customTopics.first {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 7, height: 7)
                            Text(customTopic)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.teal)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.teal.opacity(0.18)))
                        .overlay(Capsule().stroke(Color.teal.opacity(0.5), lineWidth: 1))
                    }
                }
                .frame(maxHeight: 122)
            }
            
            // Reading Progress Indicator
            VStack(spacing: 6) {
                HStack {
                    Text("\(book.currentPage) / \(book.totalPages) pages")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.75))
                    
                    Spacer()
                    
                    Text("\(book.progressPercentage)%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(book.isCompleted ? .green : NocturneTheme.purpleBright)
                }
                
                // Custom Sleek Liquid Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: book.isCompleted
                                        ? [Color.green, Color(red: 0.2, green: 0.8, blue: 0.5)]
                                        : [NocturneTheme.purpleBright, Color(red: 0.38, green: 0.82, blue: 0.98)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, geo.size.width * CGFloat(book.progressFraction)), height: 6)
                            .shadow(color: NocturneTheme.purplePrimary.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 6)
            }
            
            // Daily Photo Notes Count (Apple Notes Style)
            HStack(spacing: 6) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Text("\(book.notesCount) daily photo \(book.notesCount == 1 ? "note" : "notes")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.65))
                
                Spacer()
                
                if let lastRead = book.lastReadDate {
                    Text("Read \(timeAgo(date: lastRead))")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.40))
                }
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                // Overview & Notes Button
                Button(action: onOpenDetail) {
                    HStack(spacing: 5) {
                        Image(systemName: "note.text")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Overview & Notes")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.08))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
                
                // Log Pages Button (1 log per day enforcement)
                Button(action: {
                    if !hasLoggedToday {
                        onLogPages()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: hasLoggedToday ? "checkmark" : "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(hasLoggedToday ? "Logged Today" : "Log Pages")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(hasLoggedToday ? Color.green : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(hasLoggedToday ? Color.green.opacity(0.18) : NocturneTheme.purplePrimary)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(hasLoggedToday ? Color.green.opacity(0.4) : NocturneTheme.purpleBright, lineWidth: 1))
                    )
                }
                .disabled(hasLoggedToday)
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .liquidCard(cornerRadius: 18)
    }
    
    // Status Badge View
    @ViewBuilder
    private func statusBadge(for status: ReadingStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(status.rawValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(status.badgeColor.opacity(0.18)))
        .overlay(Capsule().stroke(status.badgeColor.opacity(0.5), lineWidth: 1))
        .foregroundColor(status.badgeColor)
    }
    
    private func timeAgo(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
