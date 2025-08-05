import SwiftUI

struct UserInfoView: View {
    let user: User
    let timestamp: Date
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.blue.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timestamp.timeAgoDisplay())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // More options button
            Button(action: {
                // Handle more options
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    let user = User(
        id: "user1",
        username: "johndoe",
        displayName: "John Doe",
        profileImageURL: "https://picsum.photos/50/50?random=1",
        isVerified: true
    )
    
    return UserInfoView(user: user, timestamp: Date().addingTimeInterval(-3600))
        .padding()
        .background(Color(.secondarySystemBackground))
        .preferredColorScheme(.dark)
} 
