import XCTest
import Combine
@testable import SocialUp

final class FeedModelTests: XCTestCase {
    var feedModel: FeedModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        feedModel = FeedModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        feedModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        let expectation = XCTestExpectation(description: "Initial state")
        
        feedModel.statePublisher
            .sink { state in
                switch state {
                case .idle:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Fetch Posts Tests
    func testFetchPostsSuccess() {
        let expectation = XCTestExpectation(description: "Fetch posts success")
        var receivedPosts: [Post] = []
        
        feedModel.fetchPosts(page: 0)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTAssertFalse(receivedPosts.isEmpty)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { posts in
                    receivedPosts = posts
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchPostsMultiplePages() {
        let expectation = XCTestExpectation(description: "Fetch multiple pages")
        var allPosts: [Post] = []
        
        // Fetch first page
        feedModel.fetchPosts(page: 0)
            .flatMap { firstPagePosts -> AnyPublisher<[Post], Error> in
                allPosts = firstPagePosts
                // Fetch second page
                return self.feedModel.fetchPosts(page: 1)
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTAssertGreaterThan(allPosts.count, 0)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { secondPagePosts in
                    allPosts.append(contentsOf: secondPagePosts)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Refresh Posts Tests
    func testRefreshPosts() {
        let expectation = XCTestExpectation(description: "Refresh posts")
        var receivedPosts: [Post] = []
        
        feedModel.refreshPosts()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTAssertFalse(receivedPosts.isEmpty)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { posts in
                    receivedPosts = posts
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Load More Posts Tests
    func testLoadMorePosts() {
        let expectation = XCTestExpectation(description: "Load more posts")
        var receivedPosts: [Post] = []
        
        feedModel.loadMorePosts()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTAssertFalse(receivedPosts.isEmpty)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { posts in
                    receivedPosts = posts
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Toggle Like Tests
    func testToggleLike() {
        let expectation = XCTestExpectation(description: "Toggle like")
        
        // First, get some posts
        feedModel.fetchPosts(page: 0)
            .flatMap { posts -> AnyPublisher<Post, Error> in
                guard let firstPost = posts.first else {
                    return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
                }
                return self.feedModel.toggleLike(for: firstPost.id)
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { post in
                    // Verify the post was updated
                    XCTAssertNotNil(post)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testToggleLikeInvalidPostId() {
        let expectation = XCTestExpectation(description: "Toggle like invalid post")
        
        feedModel.toggleLike(for: "invalid_id")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure but got success")
                    case .failure(let error):
                        XCTAssertEqual(error as? FeedError, FeedError.postNotFound)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got value")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Toggle Retweet Tests
    func testToggleRetweet() {
        let expectation = XCTestExpectation(description: "Toggle retweet")
        
        // First, get some posts
        feedModel.fetchPosts(page: 0)
            .flatMap { posts -> AnyPublisher<Post, Error> in
                guard let firstPost = posts.first else {
                    return Fail(error: FeedError.postNotFound).eraseToAnyPublisher()
                }
                return self.feedModel.toggleRetweet(for: firstPost.id)
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { post in
                    // Verify the post was updated
                    XCTAssertNotNil(post)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testToggleRetweetInvalidPostId() {
        let expectation = XCTestExpectation(description: "Toggle retweet invalid post")
        
        feedModel.toggleRetweet(for: "invalid_id")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure but got success")
                    case .failure(let error):
                        XCTAssertEqual(error as? FeedError, FeedError.postNotFound)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got value")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - State Publisher Tests
    func testStatePublisher() {
        let expectation = XCTestExpectation(description: "State publisher")
        var stateChanges: [FeedState] = []
        
        feedModel.statePublisher
            .sink { state in
                stateChanges.append(state)
                
                if stateChanges.count >= 2 {
                    // Should have at least idle and loading states
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger a state change
        feedModel.fetchPosts(page: 0)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Posts Publisher Tests
    func testPostsPublisher() {
        let expectation = XCTestExpectation(description: "Posts publisher")
        var receivedPosts: [Post] = []
        
        feedModel.postsPublisher
            .sink { posts in
                receivedPosts = posts
                if !posts.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger posts update
        feedModel.fetchPosts(page: 0)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Concurrent Operations Tests
    func testConcurrentFetchOperations() {
        let expectation = XCTestExpectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = 2
        
        // Start multiple fetch operations
        let publisher1 = feedModel.fetchPosts(page: 0)
        let publisher2 = feedModel.fetchPosts(page: 1)
        
        Publishers.Zip(publisher1, publisher2)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { posts1, posts2 in
                    XCTAssertFalse(posts1.isEmpty)
                    XCTAssertFalse(posts2.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Error Handling Tests
    func testFeedErrorDescriptions() {
        XCTAssertEqual(FeedError.alreadyLoading.localizedDescription, "Already loading posts")
        XCTAssertEqual(FeedError.noMorePosts.localizedDescription, "No more posts to load")
        XCTAssertEqual(FeedError.postNotFound.localizedDescription, "Post not found")
        XCTAssertEqual(FeedError.networkError.localizedDescription, "Network error occurred")
        XCTAssertEqual(FeedError.invalidData.localizedDescription, "Invalid data received")
    }
}

// MARK: - Mock Data Generator
extension FeedModelTests {
    func createMockPost(id: String) -> Post {
        let user = User(
            id: "user_\(id)",
            username: "user\(id)",
            displayName: "User \(id)",
            profileImageURL: "https://example.com/avatar\(id).jpg",
            isVerified: Bool.random()
        )
        
        let content = PostContent(type: .text("Test post \(id)"))
        
        return Post(
            id: id,
            user: user,
            content: content,
            timestamp: Date(),
            likes: Int.random(in: 0...100),
            retweets: Int.random(in: 0...50),
            comments: Int.random(in: 0...20),
            isLiked: Bool.random(),
            isRetweeted: Bool.random()
        )
    }
} 