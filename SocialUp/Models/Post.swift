import Foundation
import SwiftUI

// MARK: - Post Content Types
enum PostContentType {
    case text(String)
    case image(String, caption: String?)
    case video(String, thumbnail: String, caption: String?)
    case mixed(text: String, media: [PostMedia])
}

enum PostMedia {
    case image(String)
    case video(String, thumbnail: String)
}

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    let username: String
    let displayName: String
    let profileImageURL: String?
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, username, displayName
        case profileImageURL = "profileImageURL"
        case isVerified = "isVerified"
    }
}

// MARK: - Post Model
struct Post: Identifiable, Codable {
    let id: String
    let user: User
    let content: PostContent
    let timestamp: Date
    let likes: Int
    let retweets: Int
    let comments: Int
    let isLiked: Bool
    let isRetweeted: Bool
    
    var contentHeight: CGFloat {
        content.calculateHeight()
    }
}

// MARK: - Post Content
struct PostContent: Codable {
    let type: PostContentType
    let text: String?
    let media: [PostMedia]?
    
    init(type: PostContentType) {
        self.type = type
        switch type {
        case .text(let text):
            self.text = text
            self.media = nil
        case .image(let url, let caption):
            self.text = caption
            self.media = [.image(url)]
        case .video(let url, let thumbnail, let caption):
            self.text = caption
            self.media = [.video(url, thumbnail: thumbnail)]
        case .mixed(let text, let media):
            self.text = text
            self.media = media
        }
    }
    
    func calculateHeight() -> CGFloat {
        var height: CGFloat = 0
        
        // Base height for user info and actions
        height += 60 // User info height
        height += 40 // Action buttons height
        
        // Text content height
        if let text = text, !text.isEmpty {
            let estimatedHeight = text.estimatedHeight(width: UIScreen.main.bounds.width - 80, font: .systemFont(ofSize: 16))
            height += estimatedHeight + 16
        }
        
        // Media content height
        if let media = media, !media.isEmpty {
            let mediaHeight = calculateMediaHeight(media: media)
            height += mediaHeight
        }
        
        return height
    }
    
    private func calculateMediaHeight(media: [PostMedia]) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 80
        let maxHeight: CGFloat = 300
        
        if media.count == 1 {
            return maxHeight
        } else if media.count == 2 {
            return maxHeight / 2
        } else {
            return maxHeight
        }
    }
}

// MARK: - Extensions
extension String {
    func estimatedHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

// MARK: - Codable Extensions for PostContentType and PostMedia
extension PostContentType: Codable {
    enum CodingKeys: String, CodingKey {
        case type, text, imageURL, videoURL, thumbnailURL, caption, media
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let url, let caption):
            try container.encode("image", forKey: .type)
            try container.encode(url, forKey: .imageURL)
            try container.encodeIfPresent(caption, forKey: .caption)
        case .video(let url, let thumbnail, let caption):
            try container.encode("video", forKey: .type)
            try container.encode(url, forKey: .videoURL)
            try container.encode(thumbnail, forKey: .thumbnailURL)
            try container.encodeIfPresent(caption, forKey: .caption)
        case .mixed(let text, let media):
            try container.encode("mixed", forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encode(media, forKey: .media)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case "image":
            let url = try container.decode(String.self, forKey: .imageURL)
            let caption = try container.decodeIfPresent(String.self, forKey: .caption)
            self = .image(url, caption: caption)
        case "video":
            let url = try container.decode(String.self, forKey: .videoURL)
            let thumbnail = try container.decode(String.self, forKey: .thumbnailURL)
            let caption = try container.decodeIfPresent(String.self, forKey: .caption)
            self = .video(url, thumbnail: thumbnail, caption: caption)
        case "mixed":
            let text = try container.decode(String.self, forKey: .text)
            let media = try container.decode([PostMedia].self, forKey: .media)
            self = .mixed(text: text, media: media)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type")
        }
    }
}

extension PostMedia: Codable {
    enum CodingKeys: String, CodingKey {
        case type, url, thumbnail
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .image(let url):
            try container.encode("image", forKey: .type)
            try container.encode(url, forKey: .url)
        case .video(let url, let thumbnail):
            try container.encode("video", forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encode(thumbnail, forKey: .thumbnail)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "image":
            let url = try container.decode(String.self, forKey: .url)
            self = .image(url)
        case "video":
            let url = try container.decode(String.self, forKey: .url)
            let thumbnail = try container.decode(String.self, forKey: .thumbnail)
            self = .video(url, thumbnail: thumbnail)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown media type")
        }
    }
} 