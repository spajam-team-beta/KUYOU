import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingRewriteSheet = false
    
    init(blackHistory: BlackHistoryModel) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(blackHistory: blackHistory))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    blackHistorySection
                    
                    if viewModel.blackHistory.isResolved {
                        resolvedBanner
                    }
                    
                    rewritesSection
                }
                .padding()
            }
            .navigationTitle("黒歴史詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRewriteSheet) {
                RewriteSheet(viewModel: viewModel)
            }
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay(
                ascensionOverlay
            )
        }
    }
    
    private var blackHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(viewModel.blackHistory.category.rawValue, systemImage: viewModel.blackHistory.category.icon)
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
                
                salvationButton
            }
            
            Text(viewModel.blackHistory.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.blackHistory.emotionTags, id: \.self) { tag in
                        Text("#\(tag.rawValue)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(tag.color).opacity(0.2))
                            .foregroundColor(Color(tag.color))
                            .cornerRadius(10)
                    }
                }
            }
            
            Text(formatDate(viewModel.blackHistory.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var salvationButton: some View {
        Button(action: {
            viewModel.giveSalvation()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "hands.sparkles.fill")
                Text("\(viewModel.blackHistory.salvationCount)")
                    .fontWeight(.semibold)
            }
            .font(.callout)
            .foregroundColor(.purple)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    private var resolvedBanner: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("成仏済み")
                    .font(.headline)
                Text("ベストアンサーが選ばれました")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .foregroundColor(.green)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var rewritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("智慧の泉", systemImage: "lightbulb.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.blackHistory.isResolved {
                    Button(action: {
                        showingRewriteSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("リライト案を投稿")
                        }
                        .font(.caption)
                        .foregroundColor(.purple)
                    }
                }
            }
            
            if viewModel.isLoadingRewrites {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if viewModel.rewrites.isEmpty {
                Text("まだリライト案がありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(viewModel.rewrites) { rewrite in
                    RewriteCard(
                        rewrite: rewrite,
                        isOwner: true,
                        onLike: {
                            viewModel.likeRewrite(rewrite)
                        },
                        onSelectBest: {
                            viewModel.selectBestAnswer(rewrite)
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var ascensionOverlay: some View {
        if viewModel.showAscensionEffect {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 100))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(viewModel.showAscensionEffect ? 360 : 0))
                        .animation(.linear(duration: 2), value: viewModel.showAscensionEffect)
                    
                    Text("成仏")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("黒歴史が浄化されました")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .scaleEffect(viewModel.showAscensionEffect ? 1 : 0)
                .opacity(viewModel.showAscensionEffect ? 1 : 0)
                .animation(.spring(response: 0.6), value: viewModel.showAscensionEffect)
            }
            .onTapGesture {
                viewModel.showAscensionEffect = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct RewriteCard: View {
    let rewrite: RewriteModel
    let isOwner: Bool
    let onLike: () -> Void
    let onSelectBest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(rewrite.route.rawValue, systemImage: rewrite.route.icon)
                    .font(.caption)
                    .foregroundColor(Color(rewrite.route.color))
                
                Spacer()
                
                if rewrite.isBestAnswer {
                    Label("ベストアンサー", systemImage: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Text(rewrite.content)
                .font(.body)
            
            HStack {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        Text("\(rewrite.likeCount)")
                    }
                    .font(.caption)
                    .foregroundColor(.pink)
                }
                
                Spacer()
                
                if isOwner && !rewrite.isBestAnswer {
                    Button(action: onSelectBest) {
                        Text("ベストアンサーに選ぶ")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(
            rewrite.isBestAnswer ? Color.orange.opacity(0.1) : Color(.systemGray6)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    rewrite.isBestAnswer ? Color.orange.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

struct RewriteSheet: View {
    @ObservedObject var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("この黒歴史をどう解釈しますか？")
                    .font(.headline)
                    .padding(.top)
                
                Picker("ルート選択", selection: $viewModel.selectedRoute) {
                    ForEach(RewriteRoute.allCases, id: \.self) { route in
                        Label(route.rawValue, systemImage: route.icon)
                            .tag(route)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack(alignment: .trailing, spacing: 8) {
                    TextEditor(text: $viewModel.rewriteContent)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Text("\(viewModel.remainingCharacters)文字")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("リライト案を投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("投稿") {
                        viewModel.submitRewrite()
                    }
                    .disabled(!viewModel.canSubmitRewrite)
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(blackHistory: BlackHistoryModel.mockData[0])
    }
}