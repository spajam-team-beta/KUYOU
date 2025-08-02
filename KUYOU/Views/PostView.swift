import SwiftUI

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingSuccessOverlay = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    contentInputSection
                    categorySection
                    emotionTagSection
                    submitButton
                }
                .padding()
            }
            .navigationTitle("懺悔の間")
            .navigationBarTitleDisplayMode(.large)
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay(successOverlay)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 48))
                .foregroundColor(.purple)
            
            Text("あなたの黒歴史を供養します")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    private var contentInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("黒歴史を懺悔", systemImage: "pencil.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.remainingCharacters)文字")
                    .font(.caption)
                    .foregroundColor(viewModel.remainingCharacters < 50 ? .red : .secondary)
            }
            
            TextEditor(text: $viewModel.content)
                .focused($isTextFieldFocused)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("カテゴリを選択", systemImage: "folder.circle.fill")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category,
                        action: { viewModel.selectedCategory = category }
                    )
                }
            }
        }
    }
    
    private var emotionTagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("感情タグ（最大3つ）", systemImage: "tag.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.selectedEmotionTags.count)/3")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                ForEach(EmotionTag.allCases, id: \.self) { tag in
                    EmotionTagChip(
                        tag: tag,
                        isSelected: viewModel.selectedEmotionTags.contains(tag),
                        action: { viewModel.toggleEmotionTag(tag) }
                    )
                    .disabled(
                        !viewModel.selectedEmotionTags.contains(tag) &&
                        viewModel.selectedEmotionTags.count >= 3
                    )
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            isTextFieldFocused = false
            viewModel.post()
        }) {
            HStack {
                if viewModel.isPosting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("供養に出す")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.canPost ? Color.purple : Color.gray
            )
            .cornerRadius(12)
        }
        .disabled(!viewModel.canPost)
    }
    
    @ViewBuilder
    private var successOverlay: some View {
        if viewModel.showSuccessAnimation {
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
                    
                    Text("+\(PointsConstants.postBlackHistory) 徳ポイント")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                .scaleEffect(viewModel.showSuccessAnimation ? 1 : 0)
                .animation(.spring(), value: viewModel.showSuccessAnimation)
            }
        }
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct EmotionTagChip: View {
    let tag: EmotionTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color(tag.color) : Color(.systemGray5)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(tag.color).opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}