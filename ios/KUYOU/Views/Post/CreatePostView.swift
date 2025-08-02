import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreatePostViewModel()
    @State private var showSuccessAnimation = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.purple)
                    
                    Text("あなたの黒歴史を供養します")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Form
                VStack(alignment: .leading, spacing: 16) {
                    // Category selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("カテゴリ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(PostCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: viewModel.selectedCategory == category,
                                        action: { viewModel.selectedCategory = category }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("内容")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(viewModel.content.count)/1000")
                                .font(.caption2)
                                .foregroundColor(viewModel.content.count > 900 ? .orange : .secondary)
                        }
                        
                        TextEditor(text: $viewModel.content)
                            .focused($isTextFieldFocused)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .frame(minHeight: 150)
                            .overlay(
                                Group {
                                    if viewModel.content.isEmpty {
                                        Text("恥ずかしかった出来事を書いてください...\n\n例：告白しようとしたら相手の名前を間違えて呼んでしまった...")
                                            .font(.body)
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(12)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Notice
                    VStack(alignment: .leading, spacing: 4) {
                        Label("投稿時の注意", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("• 個人を特定できる情報は書かないでください\n• 他人を傷つける内容は投稿できません\n• 投稿すると10ポイントの徳が積まれます")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isTextFieldFocused = false
                        viewModel.createPost {
                            showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("供養に出す")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.canPost)
                }
            }
            .overlay(successOverlay)
        }
    }
    
    @ViewBuilder
    private var successOverlay: some View {
        if showSuccessAnimation {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("供養完了")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("+10 徳ポイント")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                .scaleEffect(showSuccessAnimation ? 1 : 0)
                .animation(.spring(), value: showSuccessAnimation)
            }
        }
    }
}

struct CategoryButton: View {
    let category: PostCategory
    let isSelected: Bool
    let action: () -> Void
    
    var categoryIcon: String {
        switch category {
        case .love: return "heart.fill"
        case .work: return "briefcase.fill"
        case .school: return "graduationcap.fill"
        case .family: return "house.fill"
        case .friend: return "person.2.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: categoryIcon)
                    .font(.caption)
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.purple : Color(.systemGray5)
            )
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .cornerRadius(20)
        }
    }
}