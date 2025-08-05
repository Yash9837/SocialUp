import SwiftUI
import Combine

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var refreshTrigger = UUID()
    @State private var showNewPostSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.isInitialLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.state.posts) { post in
                                FeedItemView(
                                    post: post,
                                    onLike: {
                                        viewModel.toggleLike(for: post.id)
                                    },
                                    onRetweet: {
                                        viewModel.toggleRetweet(for: post.id)
                                    },
                                    onComment: {
                                        // Handle comment action
                                    },
                                    onShare: {
                                        // Handle share action
                                    }
                                )
                                .onAppear {
                                    // Trigger infinite scrolling
                                    if post.id == viewModel.state.posts.last?.id {
                                        viewModel.loadMorePosts()
                                    }
                                }
                            }
                            
                            // Loading indicator for infinite scroll
                            if viewModel.isLoadingMore {
                                LoadingIndicator()
                                    .frame(height: 50)
                                    .padding()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .refreshable {
                        viewModel.refreshPosts()
                    }
                }
            }
            .navigationTitle("SocialUp")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showNewPostSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshPosts()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showNewPostSheet) {
            NewPostView()
        }
        .onAppear {
            if viewModel.state.posts.isEmpty {
                viewModel.loadInitialPosts()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.shouldShowError)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - New Post View
struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("New Post")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Post") {
                            // Handle post creation
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(postText.isEmpty ? .gray : .blue)
                        .disabled(postText.isEmpty)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                    Divider()
                        .background(Color(.separator))
                    
                    // Post content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Text input
                            TextField("What's happening?", text: $postText, axis: .vertical)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .lineLimit(5...10)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            
                            // Selected image preview
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Bottom toolbar
                    HStack(spacing: 20) {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            // Handle camera
                        }) {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("\(postText.count)/280")
                            .font(.caption)
                            .foregroundColor(postText.count > 280 ? .red : .secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Loading Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Loading posts...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct LoadingIndicator: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.blue)
            Text("Loading more posts...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No posts yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Pull to refresh to load posts")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorStateView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    FeedView()
} 