# SocialUp - Modern Social Media Feed App

A Twitter-like social media feed application built with **SwiftUI** and **Combine**, demonstrating advanced iOS development concepts using **MVVM architecture** without third-party libraries.

## 🎨 Modern UI Design

<img width="395" height="791" alt="Screenshot 2025-08-06 at 01 46 25" src="https://github.com/user-attachments/assets/4a2d43a5-bc67-45a3-aad0-d52166bfaf7a" />
<img width="394" height="793" alt="Screenshot 2025-08-06 at 01 46 08" src="https://github.com/user-attachments/assets/3aed8647-bc60-4d06-8b79-d6cfbda3e94f" />



### Visual Enhancements
- **Card-based Design**: Each post features rounded corners and subtle shadows for a modern, elevated look
- **Circular Profile Pictures**: Enhanced user avatars with blue borders and shadows
- **Animated Interactions**: Spring animations for likes, retweets, and button presses
- **Color-coded Actions**: Different colors for different actions (red for likes, green for retweets, blue for comments)
- **Enhanced Typography**: Better text formatting with hashtag and mention highlighting

### Interactive Features
- **Tap Feedback**: Posts respond to taps with subtle scale animations
- **Real-time Updates**: Immediate UI updates for all interactions
- **Pull-to-Refresh**: Smooth refresh animation with loading states
- **Infinite Scrolling**: Seamless loading of additional content

## 🚀 Key Features

### Core Functionality
- ✅ **MVVM Architecture**: Clean separation of concerns
- ✅ **Combine Integration**: Reactive data binding and state management
- ✅ **Feed Display**: Posts with text, images, and user information
- ✅ **Pull-to-Refresh**: Swipe down to refresh the feed
- ✅ **Infinite Scrolling**: Load more posts as you scroll
- ✅ **Post Creation**: Create and share your own posts
- ✅ **Media Support**: Images and videos with full-screen viewing

### Modern UI Elements
- ✅ **Card Design**: Rounded corners and shadows for posts
- ✅ **Animated Buttons**: Spring animations for interactions
- ✅ **Enhanced Typography**: Hashtag and mention highlighting
- ✅ **Circular Avatars**: Modern profile picture design
- ✅ **Color-coded Actions**: Visual feedback for different actions
- ✅ **Responsive Layout**: Adaptive design for different content types

## 🏗️ Architecture

### MVVM + Combine Implementation
```swift
// Model Layer - Data and Business Logic
class FeedModel: FeedModelProtocol {
    private let postsSubject = CurrentValueSubject<[Post], Never>([])
    func fetchPosts(page: Int) -> AnyPublisher<[Post], Error>
}

// ViewModel Layer - UI State Management
class FeedViewModel: ObservableObject {
    @Published var state = FeedViewState()
    func loadInitialPosts()
    func refreshPosts()
}

// View Layer - UI Components
struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
}
```

### Data Flow

```mermaid
graph TD
    A[Model Layer] -->|Combine Publishers| B[ViewModel Layer]
    B -->|@Published Properties| C[View Layer]
    C -->|User Actions| B
    B -->|Method Calls| A
```

## 📱 User Experience

### Interactive Elements
- **Like/Retweet**: Animated buttons with immediate feedback
- **Post Creation**: Full-featured post creation with image support
- **Media Viewing**: Full-screen image and video viewing
- **Real-time Updates**: Instant UI updates for all interactions

### Visual Design
- **Modern Cards**: Elevated post design with shadows
- **Enhanced Typography**: Formatted text with hashtag highlighting
- **Animated Interactions**: Smooth animations for all user actions
- **Color-coded Actions**: Visual distinction for different interactions

## 🧪 Testing

### Comprehensive Test Coverage
- **Unit Tests**: ViewModel and Model layer testing
- **Mock Implementations**: Isolated testing without UI dependencies
- **Testable Architecture**: Clean separation for easy testing

## 🔧 Technical Implementation

### File Structure
```
SocialUp/
├── Models/
│   ├── Post.swift
│   └── FeedModel.swift
├── ViewModels/
│   └── FeedViewModel.swift
├── Views/
│   ├── FeedView.swift
│   └── Components/
│       ├── UserInfoView.swift
│       ├── PostContentView.swift
│       ├── PostActionsView.swift
│       └── FeedItemView.swift
└── Tests/
    ├── FeedViewModelTests.swift
    └── FeedModelTests.swift
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **MVVM**: Clean architecture pattern
- **UIKit Integration**: Image picker and video player

## 🎯 Features Implemented

### Core Requirements ✅
- **MVVM Architecture**: Clear separation, no third-party libraries
- **Combine Integration**: Reactive data binding and state management
- **Feed Functionality**: Posts, pull-to-refresh, infinite scrolling
- **UI Modularity**: Reusable components and multiple content types
- **Dynamic Layouts**: Adaptive height calculation and responsive design

### Enhanced Features ✅
- **Modern UI Design**: Card-based layout with shadows and animations
- **Post Creation**: Full-featured post creation with image support
- **Enhanced Typography**: Hashtag and mention highlighting
- **Animated Interactions**: Spring animations for all user actions
- **Real-time Updates**: Immediate UI feedback for all interactions

## 🚀 Getting Started

1. **Clone the repository**
2. **Open in Xcode**
3. **Build and run on iOS Simulator or device**
4. **Enjoy the modern social media experience!**

## 📸 Screenshots

The app features:
- Modern card-based post design
- Animated interaction buttons
- Enhanced typography with hashtag highlighting
- Circular profile pictures with borders
- Full-screen media viewing
- Post creation with image support

## 🎉 Conclusion

SocialUp demonstrates **production-ready** iOS development with:
- ✅ **Modern UI/UX**: Engaging and visually appealing design
- ✅ **Clean Architecture**: MVVM + Combine implementation
- ✅ **Comprehensive Testing**: Full test coverage
- ✅ **Real-world Features**: Post creation, media support, real-time updates


The app serves as an excellent example of modern iOS development best practices using SwiftUI and Combine for reactive programming. 
