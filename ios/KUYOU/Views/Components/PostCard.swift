import SwiftUI

struct PostCard: View {
    let post: Post
    let onSympathy: () -> Void
    
    var body: some View {
        NavigationLink(destination: PostDetailView(postId: post.id)) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.nickname)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text(formatDate(post.createdAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CategoryBadge(category: post.category)
                }
                
                // Content
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                
                // Status indicator
                if post.isResolved {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("成仏済み")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Footer
                HStack(spacing: 20) {
                    // Sympathy button
                    Button(action: onSympathy) {
                        HStack(spacing: 4) {
                            Image(systemName: post.hasSympathized ?? false ? "hands.clap.fill" : "hands.clap")
                                .font(.system(size: 16))
                            Text("\(post.sympathyCount)")
                                .font(.caption)
                        }
                        .foregroundColor(post.hasSympathized ?? false ? .purple : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!AuthService.shared.isAuthenticated)
                    
                    // Reply count
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                        Text("\(post.replyCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Mine indicator
                    if post.isMine ?? false {
                        Text("自分の投稿")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CategoryBadge: View {
    let category: String
    
    var categoryDisplay: String {
        PostCategory(rawValue: category)?.displayName ?? "その他"
    }
    
    var categoryColor: Color {
        switch category {
        case "love": return .pink
        case "work": return .blue
        case "school": return .green
        case "family": return .orange
        case "friend": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Text(categoryDisplay)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(8)
    }
}