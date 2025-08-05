import SwiftUI

struct FeedItemView: View {
    let post: Post
    let onLike: () -> Void
    let onRetweet: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    
    @State private var isLiked: Bool
    @State private var isRetweeted: Bool
    @State private var showFullPost = false
    
    init(post: Post, onLike: @escaping () -> Void, onRetweet: @escaping () -> Void, onComment: @escaping () -> Void, onShare: @escaping () -> Void) {
        self.post = post
        self.onLike = onLike
        self.onRetweet = onRetweet
        self.onComment = onComment
        self.onShare = onShare
        self._isLiked = State(initialValue: post.isLiked)
        self._isRetweeted = State(initialValue: post.isRetweeted)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main post card
            VStack(alignment: .leading, spacing: 12) {
                // User info section
                UserInfoView(user: post.user, timestamp: post.timestamp)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                // Post content
                PostContentView(content: post.content)
                
                // Interaction bar
                PostActionsView(
                    likes: post.likes,
                    retweets: post.retweets,
                    comments: post.comments,
                    isLiked: $isLiked,
                    isRetweeted: $isRetweeted,
                    onLike: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isLiked.toggle()
                        }
                        onLike()
                    },
                    onRetweet: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isRetweeted.toggle()
                        }
                        onRetweet()
                    },
                    onComment: onComment,
                    onShare: onShare
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            .scaleEffect(showFullPost ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: showFullPost)
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                showFullPost = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showFullPost = false
                }
            }
        }
    }
}

#Preview {
    let sampleUser = User(
        id: "user1",
        username: "johndoe",
        displayName: "John Doe",
        profileImageURL: "https://picsum.photos/50/50?random=1",
        isVerified: true
    )
    
    let samplePost = Post(
        id: "post1",
        user: sampleUser,
        content: PostContent(type: .text("This is a sample post with some hashtags #iOS #SwiftUI 🚀")),
        timestamp: Date(),
        likes: 42,
        retweets: 12,
        comments: 8,
        isLiked: false,
        isRetweeted: false
    )
    
    return FeedItemView(
        post: samplePost,
        onLike: {},
        onRetweet: {},
        onComment: {},
        onShare: {}
    )
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
} 