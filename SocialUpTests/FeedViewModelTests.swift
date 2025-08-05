import XCTest
import Combine
@testable import SocialUp

final class FeedViewModelTests: XCTestCase {
    var viewModel: FeedViewModel!
    var mockFeedModel: MockFeedModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFeedModel = MockFeedModel()
        viewModel = FeedViewModel(feedModel: mockFeedModel)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockFeedModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(viewModel.state.posts.count, 0)
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertFalse(viewModel.state.isRefreshing)
        XCTAssertTrue(viewModel.state.hasMorePosts)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(viewModel.state.currentPage, 0)
    }
    
    // MARK: - Load Initial Posts Tests
    func testLoadInitialPostsSuccess() {
        let expectation = XCTestExpectation(description: "Load initial posts")
        let mockPosts = createMockPosts(count: 5)
        
        mockFeedModel.mockPosts = mockPosts
        mockFeedModel.shouldFail = false
        
        viewModel.loadInitialPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.state.posts.count, 5)
            XCTAssertFalse(self.viewModel.state.isLoading)
            XCTAssertNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadInitialPostsFailure() {
        let expectation = XCTestExpectation(description: "Load initial posts failure")
        
        mockFeedModel.shouldFail = true
        mockFeedModel.errorToReturn = FeedError.networkError
        
        viewModel.loadInitialPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.state.posts.count, 0)
            XCTAssertFalse(self.viewModel.state.isLoading)
            XCTAssertNotNil(self.viewModel.state.errorMessage)
            XCTAssertEqual(self.viewModel.state.errorMessage, "Network error occurred")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Refresh Posts Tests
    func testRefreshPostsSuccess() {
        let expectation = XCTestExpectation(description: "Refresh posts")
        let mockPosts = createMockPosts(count: 3)
        
        mockFeedModel.mockPosts = mockPosts
        mockFeedModel.shouldFail = false
        
        viewModel.refreshPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.state.posts.count, 3)
            XCTAssertFalse(self.viewModel.state.isRefreshing)
            XCTAssertNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRefreshPostsFailure() {
        let expectation = XCTestExpectation(description: "Refresh posts failure")
        
        mockFeedModel.shouldFail = true
        mockFeedModel.errorToReturn = FeedError.networkError
        
        viewModel.refreshPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.state.isRefreshing)
            XCTAssertNotNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Load More Posts Tests
    func testLoadMorePostsSuccess() {
        let expectation = XCTestExpectation(description: "Load more posts")
        let initialPosts = createMockPosts(count: 5)
        let additionalPosts = createMockPosts(count: 3, startIndex: 5)
        
        viewModel.state.posts = initialPosts
        mockFeedModel.mockPosts = additionalPosts
        mockFeedModel.shouldFail = false
        
        viewModel.loadMorePosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.state.posts.count, 8)
            XCTAssertFalse(self.viewModel.state.isLoading)
            XCTAssertNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadMorePostsNoMorePosts() {
        let expectation = XCTestExpectation(description: "No more posts")
        
        mockFeedModel.shouldFail = true
        mockFeedModel.errorToReturn = FeedError.noMorePosts
        
        viewModel.loadMorePosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.state.hasMorePosts)
            XCTAssertFalse(self.viewModel.state.isLoading)
            XCTAssertNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Toggle Like Tests
    func testToggleLikeSuccess() {
        let expectation = XCTestExpectation(description: "Toggle like")
        let post = createMockPost(id: "1", isLiked: false, likes: 10)
        
        viewModel.state.posts = [post]
        mockFeedModel.shouldFail = false
        
        viewModel.toggleLike(for: "1")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let updatedPost = self.viewModel.state.posts.first
            XCTAssertEqual(updatedPost?.likes, 11)
            XCTAssertTrue(updatedPost?.isLiked ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testToggleLikeFailure() {
        let expectation = XCTestExpectation(description: "Toggle like failure")
        let post = createMockPost(id: "1", isLiked: false, likes: 10)
        
        viewModel.state.posts = [post]
        mockFeedModel.shouldFail = true
        mockFeedModel.errorToReturn = FeedError.postNotFound
        
        viewModel.toggleLike(for: "1")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.state.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Toggle Retweet Tests
    func testToggleRetweetSuccess() {
        let expectation = XCTestExpectation(description: "Toggle retweet")
        let post = createMockPost(id: "1", isRetweeted: false, retweets: 5)
        
        viewModel.state.posts = [post]
        mockFeedModel.shouldFail = false
        
        viewModel.toggleRetweet(for: "1")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let updatedPost = self.viewModel.state.posts.first
            XCTAssertEqual(updatedPost?.retweets, 6)
            XCTAssertTrue(updatedPost?.isRetweeted ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Computed Properties Tests
    func testComputedProperties() {
        let posts = createMockPosts(count: 3)
        viewModel.state.posts = posts
        viewModel.state.isLoading = true
        viewModel.state.hasMorePosts = true
        
        XCTAssertEqual(viewModel.postsCount, 3)
        XCTAssertTrue(viewModel.isLoadingMore)
        XCTAssertFalse(viewModel.isInitialLoading)
        XCTAssertTrue(viewModel.canLoadMore)
    }
    
    func testErrorHandling() {
        viewModel.state.errorMessage = "Test error"
        
        XCTAssertTrue(viewModel.shouldShowError)
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        
        viewModel.clearError()
        
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertFalse(viewModel.shouldShowError)
    }
    
    // MARK: - Helper Methods
    private func createMockPosts(count: Int, startIndex: Int = 0) -> [Post] {
        var posts: [Post] = []
        
        for i in startIndex..<(startIndex + count) {
            let user = User(
                id: "user_\(i)",
                username: "user\(i)",
                displayName: "User \(i)",
                profileImageURL: "https://example.com/avatar\(i).jpg",
                isVerified: Bool.random()
            )
            
            let content = PostContent(type: .text("Test post \(i)"))
            
            let post = Post(
                id: "post_\(i)",
                user: user,
                content: content,
                timestamp: Date(),
                likes: Int.random(in: 0...100),
                retweets: Int.random(in: 0...50),
                comments: Int.random(in: 0...20),
                isLiked: Bool.random(),
                isRetweeted: Bool.random()
            )
            
            posts.append(post)
        }
        
        return posts
    }
    
    private func createMockPost(id: String, isLiked: Bool, likes: Int, isRetweeted: Bool = false, retweets: Int = 0) -> Post {
        let user = User(
            id: "user_1",
            username: "user1",
            displayName: "User 1",
            profileImageURL: "https://example.com/avatar1.jpg",
            isVerified: false
        )
        
        let content = PostContent(type: .text("Test post"))
        
        return Post(
            id: id,
            user: user,
            content: content,
            timestamp: Date(),
            likes: likes,
            retweets: retweets,
            comments: 0,
            isLiked: isLiked,
            isRetweeted: isRetweeted
        )
    }
}

// MARK: - Mock Feed Model
class MockFeedModel: FeedModelProtocol {
    var mockPosts: [Post] = []
    var shouldFail = false
    var errorToReturn: Error = FeedError.networkError
    
    var postsPublisher: AnyPublisher<[Post], Never> {
        Just(mockPosts).eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<FeedState, Never> {
        Just(.loaded(mockPosts)).eraseToAnyPublisher()
    }
    
    func fetchPosts(page: Int) -> AnyPublisher<[Post], Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Just(mockPosts)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func refreshPosts() -> AnyPublisher<[Post], Error> {
        return fetchPosts(page: 0)
    }
    
    func loadMorePosts() -> AnyPublisher<[Post], Error> {
        return fetchPosts(page: 1)
    }
    
    func toggleLike(for postId: String) -> AnyPublisher<Post, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            guard let post = mockPosts.first(where: { $0.id == postId }) else {
                return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
            }
            
            let updatedPost = Post(
                id: post.id,
                user: post.user,
                content: post.content,
                timestamp: post.timestamp,
                likes: post.isLiked ? post.likes - 1 : post.likes + 1,
                retweets: post.retweets,
                comments: post.comments,
                isLiked: !post.isLiked,
                isRetweeted: post.isRetweeted
            )
            
            return Just(updatedPost)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func toggleRetweet(for postId: String) -> AnyPublisher<Post, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            guard let post = mockPosts.first(where: { $0.id == postId }) else {
                return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
            }
            
            let updatedPost = Post(
                id: post.id,
                user: post.user,
                content: post.content,
                timestamp: post.timestamp,
                likes: post.likes,
                retweets: post.isRetweeted ? post.retweets - 1 : post.retweets + 1,
                comments: post.comments,
                isLiked: post.isLiked,
                isRetweeted: !post.isRetweeted
            )
            
            return Just(updatedPost)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
} 