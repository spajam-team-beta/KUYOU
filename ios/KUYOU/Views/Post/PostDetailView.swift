import SwiftUI

struct PostDetailView: View {
    let postId: Int
    @StateObject private var viewModel = PostDetailViewModel()
    @State private var showingReplySheet = false
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("読み込み中...")
                    .padding()
            } else if let post = viewModel.post {
                VStack(alignment: .leading, spacing: 20) {
                    // Post content
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.nickname)
                                    .font(.headline)
                                
                                Text(formatDate(post.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            CategoryBadge(category: post.category)
                        }
                        
                        // Content
                        Text(post.content)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Status
                        if post.isResolved {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("この投稿は成仏しました")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Actions
                        HStack(spacing: 30) {
                            // Sympathy button
                            Button(action: {
                                viewModel.toggleSympathy()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: post.hasSympathized ?? false ? "hands.clap.fill" : "hands.clap")
                                    Text("\(post.sympathyCount) 供養")
                                        .font(.caption)
                                }
                                .foregroundColor(post.hasSympathized ?? false ? .purple : .gray)
                            }
                            .disabled(!AuthService.shared.isAuthenticated)
                            
                            // Reply button
                            if !post.isResolved {
                                Button(action: {
                                    showingReplySheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bubble.left")
                                        Text("リライト案を投稿")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                                .disabled(!AuthService.shared.isAuthenticated)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Replies section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("智慧の泉 (\(viewModel.replies.count)件)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.replies.isEmpty {
                            Text("まだリライト案がありません")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(viewModel.replies) { reply in
                                ReplyCard(
                                    reply: reply,
                                    isPostOwner: post.isMine ?? false,
                                    onSelectBest: {
                                        viewModel.selectBestReply(reply)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("投稿詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReplySheet) {
            CreateReplyView(postId: postId) {
                viewModel.loadReplies()
            }
        }
        .onAppear {
            viewModel.postId = postId
            viewModel.loadPost()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}