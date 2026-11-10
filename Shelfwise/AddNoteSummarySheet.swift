import SwiftUI
import UIKit

public struct AddNoteSummarySheet: View {
    @Environment(\.dismiss) private var dismiss
    let initialImage: UIImage
    let book: Book
    
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var images: [UIImage] = []
    @State private var summaryText: String = ""
    @State private var fromPageText: String = ""
    @State private var toPageText: String = ""
    @State private var showingCameraToAddMore: Bool = false
    @State private var selectedImageIndex: Int = 0
    
    public init(initialImage: UIImage, book: Book) {
        self.initialImage = initialImage
        self.book = book
        _fromPageText = State(initialValue: "\(book.currentPage)")
        _toPageText = State(initialValue: "\(min(book.totalPages, book.currentPage + 15))")
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Images Carousel / Multi-photo Preview
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.stack.fill")
                                        .foregroundColor(NocturneTheme.purpleBright)
                                    Text("CAPTURED NOTES (\(images.count))")
                                        .font(.caption.bold())
                                        .foregroundColor(Color.white.opacity(0.6))
                                        .tracking(1.1)
                                }
                                
                                Spacer()
                                
                                Button(action: { showingCameraToAddMore = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "camera.badge.ellipsis")
                                            .font(.caption)
                                        Text("+ Add More")
                                            .font(.caption.bold())
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.4)))
                                    .overlay(Capsule().stroke(NocturneTheme.purpleBright, lineWidth: 1))
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if !images.isEmpty {
                                // Main focused image preview
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: images[min(selectedImageIndex, images.count - 1)])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(maxHeight: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.4), radius: 8)
                                    
                                    if images.count > 1 {
                                        Button(action: {
                                            let idxToRemove = min(selectedImageIndex, images.count - 1)
                                            images.remove(at: idxToRemove)
                                            if selectedImageIndex >= images.count {
                                                selectedImageIndex = max(0, images.count - 1)
                                            }
                                        }) {
                                            Image(systemName: "trash.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.red)
                                                .background(Circle().fill(Color.black.opacity(0.8)))
                                        }
                                        .padding(8)
                                    }
                                }
                                
                                // Thumbnails strip if multiple
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(images.indices, id: \.self) { idx in
                                            Button(action: { selectedImageIndex = idx }) {
                                                Image(uiImage: images[idx])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 54, height: 54)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(selectedImageIndex == idx ? NocturneTheme.purpleBright : Color.white.opacity(0.2), lineWidth: selectedImageIndex == idx ? 2 : 1)
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Quick add button in thumbnail strip
                                        Button(action: { showingCameraToAddMore = true }) {
                                            VStack {
                                                Image(systemName: "plus")
                                                    .font(.body.bold())
                                                    .foregroundColor(NocturneTheme.purpleBright)
                                            }
                                            .frame(width: 54, height: 54)
                                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4])))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(16)
                        .liquidCard(cornerRadius: 16)
                        
                        // Book & From / To Page Details Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text(book.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                                if let topic = book.dominantTopics.first {
                                    Text(topic.shortName)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(topic.accentColor.opacity(0.2)))
                                        .foregroundColor(topic.accentColor)
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.12))
                            
                            // FROM PAGE and TO PAGE
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("From Page")
                                        .font(.caption.bold())
                                        .foregroundColor(Color.white.opacity(0.7))
                                    
                                    TextField("e.g. 10", text: $fromPageText)
                                        .keyboardType(.numberPad)
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(NocturneTheme.bgSurfaceElevated)
                                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                        )
                                }
                                
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .foregroundColor(NocturneTheme.purpleBright)
                                    .padding(.top, 18)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("To Page")
                                        .font(.caption.bold())
                                        .foregroundColor(Color.white.opacity(0.7))
                                    
                                    TextField("e.g. 35", text: $toPageText)
                                        .keyboardType(.numberPad)
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(NocturneTheme.bgSurfaceElevated)
                                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                        )
                                }
                            }
                            
                            // Calculated pages read notice
                            if let from = Int(fromPageText), let to = Int(toPageText), to >= from {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.pages")
                                        .foregroundColor(.green)
                                    Text("\(to - from + 1) pages covered today")
                                        .font(.caption.bold())
                                        .foregroundColor(.green)
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(16)
                        .liquidCard(cornerRadius: 16)
                        
                        // Daily Summary Text Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pencil.and.scribble")
                                    .foregroundColor(NocturneTheme.purpleBright)
                                Text("TODAY'S SUMMARY NOTE")
                                    .font(.caption.bold())
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .tracking(1.2)
                            }
                            
                            TextEditor(text: $summaryText)
                                .scrollContentBackground(.hidden)
                                .frame(height: 120)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(NocturneTheme.bgSurfaceElevated)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                )
                                .foregroundColor(.white)
                                .font(.body)
                                .overlay(alignment: .topLeading) {
                                    if summaryText.isEmpty {
                                        Text("Write key takeaways, insights or reflection from today's reading...")
                                            .foregroundColor(Color.white.opacity(0.3))
                                            .padding(14)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .padding(16)
                        .liquidCard(cornerRadius: 16)
                        
                        // Save Button
                        Button(action: saveNote) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.headline)
                                Text("Save Note & Cloud Sync")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NocturneTheme.purplePrimary)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Daily Reading Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .onAppear {
                if images.isEmpty {
                    images.append(initialImage)
                }
            }
            .fullScreenCover(isPresented: $showingCameraToAddMore) {
                CameraView { extraImg in
                    images.append(extraImg)
                    selectedImageIndex = images.count - 1
                }
                .ignoresSafeArea()
            }
        }
    }
    
    private func saveNote() {
        let from = Int(fromPageText.trimmingCharacters(in: .whitespacesAndNewlines))
        let to = Int(toPageText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        dataManager.addPhotoNotes(
            images: images,
            book: book,
            fromPage: from,
            toPage: to,
            summaryText: summaryText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}
