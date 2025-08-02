import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    
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
                }
                .padding()
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.refresh()
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("匿名の供養師")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(viewModel.user.totalPoints)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("徳ポイント")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.user.postedHistories.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("供養数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.user.bestAnswersReceived)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("成仏数")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                
                Text(viewModel.levelTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(viewModel.user.totalPoints) / \(viewModel.nextLevelPoints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.levelProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: viewModel.levelProgress)
                    .tint(.purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "hands.sparkles.fill",
                title: "供養した数",
                value: "\(viewModel.user.salvationGiven)",
                color: .purple
            )
            
            StatCard(
                icon: "star.fill",
                title: "ベストアンサー",
                value: "\(viewModel.user.bestAnswersReceived)",
                color: .orange
            )
            
            StatCard(
                icon: "calendar",
                title: "活動日数",
                value: "\(daysSinceJoined())日",
                color: .blue
            )
            
            StatCard(
                icon: "trophy.fill",
                title: "実績解除",
                value: "\(viewModel.user.achievements.count)/\(Achievement.allCases.count)",
                color: .yellow
            )
        }
    }
    
    private var tabSection: some View {
        Picker("表示切替", selection: $selectedTab) {
            Text("実績").tag(0)
            Text("投稿履歴").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !viewModel.unlockedAchievements.isEmpty {
                Label("解除済み実績", systemImage: "rosette")
                    .font(.headline)
                
                ForEach(viewModel.unlockedAchievements, id: \.self) { achievement in
                    AchievementRow(achievement: achievement, isUnlocked: true)
                }
            }
            
            if !viewModel.lockedAchievements.isEmpty {
                Label("未解除実績", systemImage: "lock.circle")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(viewModel.lockedAchievements, id: \.self) { achievement in
                    AchievementRow(achievement: achievement, isUnlocked: false)
                }
            }
        }
    }
    
    private var myHistoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("投稿した黒歴史", systemImage: "clock.arrow.circlepath")
                .font(.headline)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if viewModel.myHistories.isEmpty {
                Text("まだ投稿がありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(viewModel.myHistories) { history in
                    MiniHistoryCard(history: history)
                }
            }
        }
    }
    
    private func daysSinceJoined() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: viewModel.user.lastActiveDate, to: Date())
        return max(1, components.day ?? 1)
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
    let history: BlackHistoryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(history.category.rawValue, systemImage: history.category.icon)
                    .font(.caption)
                    .foregroundColor(.purple)
                
                Spacer()
                
                if history.isResolved {
                    Label("成仏済", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(history.content)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "hands.sparkles.fill")
                    Text("\(history.salvationCount)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(history.createdAt))
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
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}