import SwiftUI
import AVKit

struct PostContentView: View {
    let content: PostContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Text Content
            if let text = content.text, !text.isEmpty {
                FormattedTextView(text: text)
                    .padding(.horizontal, 16)
            }
            
            // Media Content
            if let media = content.media, !media.isEmpty {
                MediaContentView(media: media)
            }
        }
    }
}

struct FormattedTextView: View {
    let text: String
    
    var body: some View {
        Text(attributedText)
            .font(.body)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    private var attributedText: AttributedString {
        var attributedString = AttributedString(text)
        
        // Highlight hashtags
        let hashtagPattern = #/#\w+/#
        let hashtagMatches = text.matches(of: hashtagPattern)
        
        for match in hashtagMatches {
            let range = match.range
            if let attributedRange = Range<AttributedString.Index>(range, in: attributedString) {
                attributedString[attributedRange].foregroundColor = .blue
                attributedString[attributedRange].font = .system(.body, design: .default, weight: .semibold)
            }
        }
        
        // Highlight mentions
        let mentionPattern = #/@\w+/#
        let mentionMatches = text.matches(of: mentionPattern)
        
        for match in mentionMatches {
            let range = match.range
            if let attributedRange = Range<AttributedString.Index>(range, in: attributedString) {
                attributedString[attributedRange].foregroundColor = .blue
                attributedString[attributedRange].font = .system(.body, design: .default, weight: .semibold)
            }
        }
        
        return attributedString
    }
}

struct MediaContentView: View {
    let media: [PostMedia]
    
    var body: some View {
        switch media.count {
        case 1:
            SingleMediaView(media: media[0])
        case 2:
            TwoMediaView(media: media)
        default:
            MultipleMediaView(media: media)
        }
    }
}

struct SingleMediaView: View {
    let media: PostMedia
    
    var body: some View {
        switch media {
        case .image(let url):
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxHeight: 300)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.blue)
                    )
            }
            .cornerRadius(12)
            .padding(.horizontal, 16)
            
        case .video(let url, let thumbnail):
            VideoThumbnailView(videoURL: url, thumbnailURL: thumbnail)
        }
    }
}

struct TwoMediaView: View {
    let media: [PostMedia]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<min(media.count, 2), id: \.self) { index in
                switch media[index] {
                case .image(let url):
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 150)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: 150)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(.blue)
                            )
                    }
                    .clipped()
                    .cornerRadius(8)
                    
                case .video(let url, let thumbnail):
                    VideoThumbnailView(videoURL: url, thumbnailURL: thumbnail)
                        .frame(maxHeight: 150)
                        .clipped()
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct MultipleMediaView: View {
    let media: [PostMedia]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4)
        ], spacing: 4) {
            ForEach(0..<min(media.count, 4), id: \.self) { index in
                switch media[index] {
                case .image(let url):
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(.blue)
                            )
                    }
                    .clipped()
                    .cornerRadius(8)
                    
                case .video(let url, let thumbnail):
                    VideoThumbnailView(videoURL: url, thumbnailURL: thumbnail)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct VideoThumbnailView: View {
    let videoURL: String
    let thumbnailURL: String
    @State private var isPlaying = false
    @State private var thumbnailLoaded = false
    @State private var showVideoPlayer = false
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        thumbnailLoaded = true
                    }
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.blue)
                            Text("Loading video...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .frame(maxHeight: 300)
            .clipped()
            .cornerRadius(12)
            
            // Play button overlay
            if thumbnailLoaded {
                Button(action: {
                    showVideoPlayer = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showVideoPlayer) {
            VideoPlayerView(videoURL: videoURL)
        }
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .edgesIgnoringSafeArea(.all)
                } else {
                    VStack {
                        Image(systemName: "video.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Video not available")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let textContent = PostContent(type: .text("This is a sample text post with some hashtags #iOS #SwiftUI and mentions @johndoe! 🚀"))
    let imageContent = PostContent(type: .image("https://picsum.photos/400/300?random=1", caption: "Amazing photo! 📸"))
    let videoContent = PostContent(type: .video("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnail: "https://picsum.photos/400/300?random=2", caption: "Check out this video! 🎥"))
    let mixedContent = PostContent(type: .mixed(text: "Mixed content post with text and media! 📱", media: [
        .image("https://picsum.photos/200/200?random=3"),
        .image("https://picsum.photos/200/200?random=4")
    ]))
    
    return VStack(spacing: 20) {
        PostContentView(content: textContent)
        PostContentView(content: imageContent)
        PostContentView(content: videoContent)
        PostContentView(content: mixedContent)
    }
    .previewLayout(.sizeThatFits)
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
} 