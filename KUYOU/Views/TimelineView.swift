import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var selectedHistory: BlackHistoryModel?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredHistories.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            filterSection
                            
                            ForEach(viewModel.filteredHistories) { history in
                                PostCardView(
                                    blackHistory: history,
                                    onSalvation: {
                                        viewModel.giveSalvation(to: history)
                                    },
                                    onTap: {
                                        selectedHistory = history
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("供養の広場")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortMenu
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "黒歴史を検索")
            .sheet(item: $selectedHistory) { history in
                DetailView(blackHistory: history)
            }
            .onAppear {
                #if DEBUG
                if viewModel.blackHistories.isEmpty {
                    viewModel.loadMockData()
                }
                #endif
            }
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Category.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            viewModel.toggleCategory(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    viewModel.sortOption = option
                }) {
                    Label(
                        option.rawValue,
                        systemImage: viewModel.sortOption == option ? "checkmark" : option.icon
                    )
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.title3)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("まだ黒歴史がありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                Button("フィルターをクリア") {
                    viewModel.selectedCategory = nil
                    viewModel.searchText = ""
                }
                .foregroundColor(.purple)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.purple : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}