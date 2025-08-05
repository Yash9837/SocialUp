import Foundation
import Combine
import SwiftUI

// MARK: - Feed View State
struct FeedViewState {
    var posts: [Post] = []
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var hasMorePosts: Bool = true
    var errorMessage: String?
    var currentPage: Int = 0
}

// MARK: - Feed View Model
class FeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state = FeedViewState()
    
    // MARK: - Private Properties
    private let feedModel: FeedModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(feedModel: FeedModelProtocol = FeedModel()) {
        self.feedModel = feedModel
        setupBindings()
    }
    
    // MARK: - Public Methods
    func loadInitialPosts() {
        guard !state.isLoading else { return }
        
        state.isLoading = true
        state.errorMessage = nil
        
        // Add a small delay to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.feedModel.fetchPosts(page: 0)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.state.isLoading = false
                        if case .failure(let error) = completion {
                            // Don't show "already loading" error as it's not user-facing
                            if let feedError = error as? FeedError, feedError == .alreadyLoading {
                                // Just ignore this error
                            } else {
                                self?.state.errorMessage = error.localizedDescription
                            }
                        }
                    },
                    receiveValue: { [weak self] posts in
                        self?.state.posts = posts
                        self?.state.currentPage = 0
                        self?.state.hasMorePosts = posts.count >= 20
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    func refreshPosts() {
        guard !state.isRefreshing else { return }
        
        state.isRefreshing = true
        state.errorMessage = nil
        
        feedModel.refreshPosts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.state.isRefreshing = false
                    if case .failure(let error) = completion {
                        // Don't show "already loading" error as it's not user-facing
                        if let feedError = error as? FeedError, feedError == .alreadyLoading {
                            // Just ignore this error
                        } else {
                            self?.state.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] posts in
                    self?.state.posts = posts
                    self?.state.currentPage = 0
                    self?.state.hasMorePosts = posts.count >= 20
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMorePosts() {
        guard state.hasMorePosts && !state.isLoading else { return }
        
        state.isLoading = true
        state.errorMessage = nil
        
        feedModel.loadMorePosts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.state.isLoading = false
                    if case .failure(let error) = completion {
                        if let feedError = error as? FeedError, feedError == .noMorePosts {
                            self?.state.hasMorePosts = false
                        } else if let feedError = error as? FeedError, feedError == .alreadyLoading {
                            // Just ignore this error
                        } else {
                            self?.state.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] newPosts in
                    self?.state.posts.append(contentsOf: newPosts)
                    self?.state.currentPage += 1
                    self?.state.hasMorePosts = newPosts.count >= 20
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleLike(for postId: String) {
        feedModel.toggleLike(for: postId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func toggleRetweet(for postId: String) {
        feedModel.toggleRetweet(for: postId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func clearError() {
        state.errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Observe feed model state changes
        feedModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] feedState in
                self?.handleFeedStateChange(feedState)
            }
            .store(in: &cancellables)
        
        // Observe posts changes from model
        feedModel.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.state.posts = posts
            }
            .store(in: &cancellables)
    }
    
    private func handleFeedStateChange(_ feedState: FeedState) {
        switch feedState {
        case .idle:
            state.isLoading = false
            state.isRefreshing = false
            state.errorMessage = nil
            
        case .loading:
            state.isLoading = true
            state.errorMessage = nil
            
        case .refreshing:
            state.isRefreshing = true
            state.errorMessage = nil
            
        case .loaded(let posts):
            state.isLoading = false
            state.isRefreshing = false
            state.posts = posts
            state.errorMessage = nil
            
        case .error(let error):
            state.isLoading = false
            state.isRefreshing = false
            state.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Feed View Model Extensions
extension FeedViewModel {
    var postsCount: Int {
        state.posts.count
    }
    
    var canLoadMore: Bool {
        state.hasMorePosts && !state.isLoading
    }
    
    var isLoadingMore: Bool {
        state.isLoading && !state.posts.isEmpty
    }
    
    var isInitialLoading: Bool {
        state.isLoading && state.posts.isEmpty
    }
    
    var shouldShowError: Bool {
        state.errorMessage != nil
    }
    
    var errorMessage: String? {
        state.errorMessage
    }
} 