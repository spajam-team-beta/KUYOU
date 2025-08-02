import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    @State private var selectedTab = 0
    @State private var showLevelUpAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    
                    levelSection
                    
                    statsSection
                    
                    tabSection
                    
                    if selectedTab == 0 {
                        achievementsSection
                    } else {
                        myHistoriesSection
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Logout button
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("ログアウト")
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadProfile()
            }
            .alert("ログアウト", isPresented: $showingLogoutAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("ログアウト", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("本当にログアウトしますか？")
            }
            .onAppear {
                viewModel.loadProfile()
            }
            .overlay(levelUpOverlay)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
                .overlay(
                    Circle()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 3)
                        .scaleEffect(showLevelUpAnimation ? 1.2 : 1)
                        .opacity(showLevelUpAnimation ? 0 : 1)
                        .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: showLevelUpAnimation)
                )
            
            Text("匿名の供養師")
                .font(.title2)
                .fontWeight(.bold)
            
            if let user = viewModel.currentUser {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(user.totalPoints)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("徳ポイント")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(spacing: 4) {
                        Text("\(viewModel.userStats?.totalPosts ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("供養数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(spacing: 4) {
                        Text("\(viewModel.userStats?.resolvedPosts ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("成仏数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var levelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("現在のレベル", systemImage: "star.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                Text(getLevelTitle())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
            
            if let user = viewModel.currentUser {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(user.totalPoints) / \(getNextLevelPoints())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(getLevelProgress() * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: getLevelProgress())
                        .tint(.purple)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var statsSection: some View {
        Group {
            if let stats = viewModel.userStats {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        icon: "hands.sparkles.fill",
                        title: "供養した数",
                        value: "\(stats.totalSympathiesGiven)",
                        color: .purple
                    )
                    
                    StatCard(
                        icon: "star.fill",
                        title: "ベストアンサー",
                        value: "\(stats.bestReplies)",
                        color: .orange
                    )
                    
                    StatCard(
                        icon: "calendar",
                        title: "活動日数",
                        value: "\(daysSinceJoined())日",
                        color: .blue
                    )
                    
                    NavigationLink(destination: UserRankingView()) {
                        StatCard(
                            icon: "trophy.fill",
                            title: "ランキング",
                            value: "詳細を見る",
                            color: .yellow
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var tabSection: some View {
        Picker("表示切替", selection: $selectedTab.animation()) {
            Text("実績").tag(0)
            Text("投稿履歴").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("実績", systemImage: "rosette")
                .font(.headline)
            
            ForEach(Achievement.allCases, id: \.self) { achievement in
                AchievementRow(
                    achievement: achievement,
                    isUnlocked: checkAchievementUnlocked(achievement)
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    private var myHistoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("投稿した黒歴史", systemImage: "clock.arrow.circlepath")
                .font(.headline)
            
            if viewModel.myPosts.isEmpty {
                Text("まだ投稿がありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(viewModel.myPosts) { post in
                    NavigationLink(destination: PostDetailView(postId: post.id)) {
                        MiniHistoryCard(post: post)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    private var levelUpOverlay: some View {
        if showLevelUpAnimation {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(showLevelUpAnimation ? 360 : 0))
                        .animation(.linear(duration: 2), value: showLevelUpAnimation)
                    
                    Text("レベルアップ！")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(getLevelTitle())
                        .font(.title)
                        .foregroundColor(.yellow)
                }
                .scaleEffect(showLevelUpAnimation ? 1 : 0)
                .opacity(showLevelUpAnimation ? 1 : 0)
                .animation(.spring(response: 0.6), value: showLevelUpAnimation)
            }
            .onTapGesture {
                showLevelUpAnimation = false
            }
        }
    }
    
    private func getLevelTitle() -> String {
        guard let points = viewModel.currentUser?.totalPoints else { return "初心者" }
        switch points {
        case 0..<50: return "初心者"
        case 50..<100: return "修行者"
        case 100..<300: return "供養師"
        case 300..<500: return "達人"
        case 500..<1000: return "大師"
        default: return "伝説の供養師"
        }
    }
    
    private func getNextLevelPoints() -> Int {
        guard let points = viewModel.currentUser?.totalPoints else { return 50 }
        switch points {
        case 0..<50: return 50
        case 50..<100: return 100
        case 100..<300: return 300
        case 300..<500: return 500
        case 500..<1000: return 1000
        default: return points + 1000
        }
    }
    
    private func getLevelProgress() -> Double {
        guard let points = viewModel.currentUser?.totalPoints else { return 0 }
        let nextLevel = getNextLevelPoints()
        let previousLevel: Int
        
        switch points {
        case 0..<50: previousLevel = 0
        case 50..<100: previousLevel = 50
        case 100..<300: previousLevel = 100
        case 300..<500: previousLevel = 300
        case 500..<1000: previousLevel = 500
        default: previousLevel = 1000 * (points / 1000)
        }
        
        return Double(points - previousLevel) / Double(nextLevel - previousLevel)
    }
    
    private func daysSinceJoined() -> Int {
        // 仮の実装
        return 30
    }
    
    private func checkAchievementUnlocked(_ achievement: Achievement) -> Bool {
        guard let user = viewModel.currentUser, let stats = viewModel.userStats else { return false }
        
        switch achievement {
        case .firstPost: return stats.totalPosts > 0
        case .tenSalvations: return stats.totalSympathiesGiven >= 10
        case .hundredSalvations: return stats.totalSympathiesGiven >= 100
        case .thousandSalvations: return stats.totalSympathiesGiven >= 1000
        case .firstBestAnswer: return stats.bestReplies > 0
        case .tenBestAnswers: return stats.bestReplies >= 10
        case .comedyMaster, .touchingMaster, .philosophyMaster:
            return user.totalPoints >= 500
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !isUnlocked {
                    Text("必要ポイント: \(achievement.requiredPoints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isUnlocked ? Color.yellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

struct MiniHistoryCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoryBadge(category: post.category)
                
                Spacer()
                
                if post.isResolved {
                    Label("成仏済", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(post.content)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "hands.sparkles.fill")
                    Text("\(post.sympathyCount)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(post.createdAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

enum Achievement: String, CaseIterable {
    case firstPost = "初めての告白"
    case tenSalvations = "供養師見習い"
    case hundredSalvations = "供養師"
    case thousandSalvations = "供養師匠"
    case firstBestAnswer = "初めての成仏"
    case tenBestAnswers = "導師"
    case comedyMaster = "爆笑の達人"
    case touchingMaster = "感動の達人"
    case philosophyMaster = "哲学の達人"
    
    var icon: String {
        switch self {
        case .firstPost: return "pencil.circle.fill"
        case .tenSalvations, .hundredSalvations, .thousandSalvations: return "hands.sparkles.fill"
        case .firstBestAnswer, .tenBestAnswers: return "star.circle.fill"
        case .comedyMaster: return "face.smiling.fill"
        case .touchingMaster: return "heart.fill"
        case .philosophyMaster: return "brain"
        }
    }
    
    var requiredPoints: Int {
        switch self {
        case .firstPost: return 0
        case .tenSalvations: return 10
        case .hundredSalvations: return 100
        case .thousandSalvations: return 1000
        case .firstBestAnswer: return 0
        case .tenBestAnswers: return 0
        case .comedyMaster: return 500
        case .touchingMaster: return 500
        case .philosophyMaster: return 500
        }
    }
}