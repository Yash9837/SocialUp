import Foundation
import Combine

// MARK: - Feed State
enum FeedState {
    case idle
    case loading
    case loaded([Post])
    case error(Error)
    case refreshing
}

// MARK: - Feed Model Protocol
protocol FeedModelProtocol {
    var postsPublisher: AnyPublisher<[Post], Never> { get }
    var statePublisher: AnyPublisher<FeedState, Never> { get }
    
    func fetchPosts(page: Int) -> AnyPublisher<[Post], Error>
    func refreshPosts() -> AnyPublisher<[Post], Error>
    func loadMorePosts() -> AnyPublisher<[Post], Error>
    func toggleLike(for postId: String) -> AnyPublisher<Post, Error>
    func toggleRetweet(for postId: String) -> AnyPublisher<Post, Error>
}

// MARK: - Feed Model
class FeedModel: FeedModelProtocol {
    // MARK: - Properties
    private let postsSubject = CurrentValueSubject<[Post], Never>([])
    private let stateSubject = CurrentValueSubject<FeedState, Never>(.idle)
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 0
    private var hasMorePosts = true
    private var isLoading = false
    
    // MARK: - Publishers
    var postsPublisher: AnyPublisher<[Post], Never> {
        postsSubject.eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<FeedState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init() {
        // Don't auto-load posts - let ViewModel control this
    }
    
    // MARK: - Public Methods
    func fetchPosts(page: Int) -> AnyPublisher<[Post], Error> {
        guard !isLoading else {
            return Fail(error: FeedError.alreadyLoading).eraseToAnyPublisher()
        }
        
        isLoading = true
        stateSubject.send(.loading)
        
        return fetchPostsFromAPI(page: page)
            .handleEvents(receiveOutput: { [weak self] posts in
                self?.isLoading = false
                self?.currentPage = page
                self?.hasMorePosts = posts.count >= 20 // Assuming 20 posts per page
                
                if page == 0 {
                    self?.postsSubject.send(posts)
                    self?.stateSubject.send(.loaded(posts))
                } else {
                    let currentPosts = self?.postsSubject.value ?? []
                    self?.postsSubject.send(currentPosts + posts)
                    self?.stateSubject.send(.loaded(currentPosts + posts))
                }
            }, receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isLoading = false
                    self?.stateSubject.send(.error(error))
                }
            })
            .eraseToAnyPublisher()
    }
    
    func refreshPosts() -> AnyPublisher<[Post], Error> {
        stateSubject.send(.refreshing)
        currentPage = 0
        hasMorePosts = true
        
        return fetchPosts(page: 0)
    }
    
    func loadMorePosts() -> AnyPublisher<[Post], Error> {
        guard hasMorePosts && !isLoading else {
            return Fail(error: FeedError.noMorePosts).eraseToAnyPublisher()
        }
        
        return fetchPosts(page: currentPage + 1)
    }
    
    func toggleLike(for postId: String) -> AnyPublisher<Post, Error> {
        guard let postIndex = postsSubject.value.firstIndex(where: { $0.id == postId }) else {
            return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
        }
        
        var posts = postsSubject.value
        var post = posts[postIndex]
        
        // Toggle like state
        let newLikeCount = post.isLiked ? post.likes - 1 : post.likes + 1
        post = Post(
            id: post.id,
            user: post.user,
            content: post.content,
            timestamp: post.timestamp,
            likes: newLikeCount,
            retweets: post.retweets,
            comments: post.comments,
            isLiked: !post.isLiked,
            isRetweeted: post.isRetweeted
        )
        
        posts[postIndex] = post
        postsSubject.send(posts)
        
        // Simulate API call
        return Just(post)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func toggleRetweet(for postId: String) -> AnyPublisher<Post, Error> {
        guard let postIndex = postsSubject.value.firstIndex(where: { $0.id == postId }) else {
            return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
        }
        
        var posts = postsSubject.value
        var post = posts[postIndex]
        
        // Toggle retweet state
        let newRetweetCount = post.isRetweeted ? post.retweets - 1 : post.retweets + 1
        post = Post(
            id: post.id,
            user: post.user,
            content: post.content,
            timestamp: post.timestamp,
            likes: post.likes,
            retweets: newRetweetCount,
            comments: post.comments,
            isLiked: post.isLiked,
            isRetweeted: !post.isRetweeted
        )
        
        posts[postIndex] = post
        postsSubject.send(posts)
        
        // Simulate API call
        return Just(post)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    private func fetchPostsFromAPI(page: Int) -> AnyPublisher<[Post], Error> {
        // Simulate API call with mock data
        return Future { [weak self] promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let posts = self?.generateMockPosts(page: page) ?? []
                promise(.success(posts))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func generateMockPosts(page: Int) -> [Post] {
        let startIndex = page * 20
        var posts: [Post] = []
        
        for i in 0..<20 {
            let postId = "post_\(startIndex + i)"
            let userId = "user_\(Int.random(in: 1...10))"
            
            let user = User(
                id: userId,
                username: "user\(userId)",
                displayName: "User \(userId)",
                profileImageURL: "https://picsum.photos/50/50?random=\(userId)",
                isVerified: Bool.random()
            )
            
            let contentTypes: [PostContentType] = [
                .text("This is a sample text post #\(startIndex + i) with some hashtags and mentions! 🚀"),
                .image("https://picsum.photos/400/300?random=\(startIndex + i)", caption: "Amazing photo! 📸"),
                .video("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnail: "https://picsum.photos/400/300?random=\(startIndex + i)", caption: "Check out this video! 🎥"),
                .mixed(text: "Mixed content post with text and media! 📱", media: [
                    .image("https://picsum.photos/200/200?random=\(startIndex + i)"),
                    .image("https://picsum.photos/200/200?random=\(startIndex + i + 1)")
                ])
            ]
            
            let randomContentType = contentTypes.randomElement() ?? .text("Default post")
            let content = PostContent(type: randomContentType)
            
            let post = Post(
                id: postId,
                user: user,
                content: content,
                timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400 * 7)), // Random time within last week
                likes: Int.random(in: 0...1000),
                retweets: Int.random(in: 0...500),
                comments: Int.random(in: 0...200),
                isLiked: Bool.random(),
                isRetweeted: Bool.random()
            )
            
            posts.append(post)
        }
        
        return posts
    }
}

// MARK: - Feed Errors
enum FeedError: Error, LocalizedError {
    case alreadyLoading
    case noMorePosts
    case postNotFound
    case networkError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .alreadyLoading:
            return "Already loading posts"
        case .noMorePosts:
            return "No more posts to load"
        case .postNotFound:
            return "Post not found"
        case .networkError:
            return "Network error occurred"
        case .invalidData:
            return "Invalid data received"
        }
    }
} 