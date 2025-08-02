import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreatePostViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    
                    Text("懺悔の間")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("あなたの黒歴史を匿名で投稿しましょう")
                        .font(.caption)
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
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .frame(minHeight: 200)
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
                        viewModel.createPost {
                            dismiss()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("投稿")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.canPost)
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: PostCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
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