import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showingCreatePost = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Category filters
                        FilterChip(
                            title: "すべて",
                            isSelected: viewModel.selectedCategory == nil,
                            action: { viewModel.changeCategory(nil) }
                        )
                        
                        ForEach(PostCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.displayName,
                                isSelected: viewModel.selectedCategory == category,
                                action: { viewModel.changeCategory(category) }
                            )
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // Sort options
                        ForEach(TimelineViewModel.SortOption.allCases, id: \.self) { sort in
                            FilterChip(
                                title: sort.displayName,
                                isSelected: viewModel.selectedSort == sort,
                                action: { viewModel.changeSort(sort) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                // Posts list
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    Spacer()
                    ProgressView("読み込み中...")
                    Spacer()
                } else if viewModel.posts.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("投稿がありません")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.posts) { post in
                                PostCard(post: post) {
                                    viewModel.toggleSympathy(for: post)
                                }
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(post: post)
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.loadPosts(refresh: true)
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("供養の広場")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.loadPosts()
                } else {
                    // Check for updates when view appears
                    viewModel.checkForUpdates()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Check for updates when app enters foreground
                viewModel.checkForUpdates()
            }
        }
    }
    
    private func categoryIcon(for category: PostCategory) -> String {
        switch category {
        case .love: return "heart.fill"
        case .work: return "briefcase.fill"
        case .school: return "graduationcap.fill"
        case .family: return "house.fill"
        case .friend: return "person.2.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.purple : Color(.systemGray5)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .cornerRadius(15)
        }
    }
}