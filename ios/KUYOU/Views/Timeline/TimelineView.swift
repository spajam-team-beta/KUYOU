import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    
    init(viewModel: TimelineViewModel = TimelineViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                VStack(alignment: .leading, spacing: 12) {
                    Label("カテゴリを選択", systemImage: "folder.circle.fill")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(PostCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.selectedCategory == category,
                                action: { viewModel.selectedCategory = category }
                            )
                        }
                    }
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
                        Image(systemName: viewModel.isSearching ? "magnifyingglass" : "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        if viewModel.isSearching {
                            Text("「\(viewModel.searchText)」の検索結果はありません")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("検索をクリア") {
                                viewModel.clearSearch()
                            }
                            .foregroundColor(.purple)
                            .padding(.top, 8)
                        } else {
                            Text("投稿がありません")
                                .foregroundColor(.secondary)
                        }
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
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(TimelineViewModel.SortOption.allCases, id: \.self) { sort in
                                Button(action: {
                                    viewModel.changeSort(sort)
                                }) {
                                    HStack {
                                        Text(sort.displayName)
                                        if viewModel.selectedSort == sort {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.purple)
                        }
                    }
                }
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
