import SwiftUI

struct PostActionsView: View {
    let likes: Int
    let retweets: Int
    let comments: Int
    @Binding var isLiked: Bool
    @Binding var isRetweeted: Bool
    let onLike: () -> Void
    let onRetweet: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Comment Button
            ActionButton(
                icon: "bubble.left",
                count: comments,
                isActive: false,
                color: .blue
            ) {
                onComment()
            }
            
            Spacer()
            
            // Retweet Button
            ActionButton(
                icon: "arrow.2.squarepath",
                count: retweets,
                isActive: isRetweeted,
                color: .green
            ) {
                onRetweet()
            }
            
            Spacer()
            
            // Like Button
            ActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likes,
                isActive: isLiked,
                color: .red
            ) {
                onLike()
            }
            
            Spacer()
            
            // Share Button
            ActionButton(
                icon: "square.and.arrow.up",
                count: nil,
                isActive: false,
                color: .blue
            ) {
                onShare()
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let count: Int?
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isActive ? color : .secondary)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(isActive ? color : .secondary)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isActive ? color.opacity(0.2) : Color.clear)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        PostActionsView(
            likes: 42,
            retweets: 12,
            comments: 8,
            isLiked: .constant(false),
            isRetweeted: .constant(false),
            onLike: {},
            onRetweet: {},
            onComment: {},
            onShare: {}
        )
        
        PostActionsView(
            likes: 128,
            retweets: 45,
            comments: 23,
            isLiked: .constant(true),
            isRetweeted: .constant(true),
            onLike: {},
            onRetweet: {},
            onComment: {},
            onShare: {}
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .preferredColorScheme(.dark)
} 