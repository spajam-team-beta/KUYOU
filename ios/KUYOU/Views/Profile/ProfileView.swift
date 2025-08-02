import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User info card
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        if let user = viewModel.currentUser {
                            Text(user.email)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(user.totalPoints) 徳ポイント")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Stats card
                    if let stats = viewModel.userStats {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("統計")
                                .font(.headline)
                            
                            StatsGrid(stats: stats)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        NavigationLink(destination: UserRankingView()) {
                            HStack {
                                Image(systemName: "trophy")
                                Text("ランキング")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
                        }
                    }
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

struct StatsGrid: View {
    let stats: UserStats
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatItem(title: "総投稿数", value: "\(stats.totalPosts)")
            StatItem(title: "成仏済み", value: "\(stats.resolvedPosts)")
            StatItem(title: "総リライト案", value: "\(stats.totalReplies)")
            StatItem(title: "ベストアンサー", value: "\(stats.bestReplies)")
            StatItem(title: "供養した数", value: "\(stats.totalSympathiesGiven)")
            StatItem(title: "供養された数", value: "\(stats.totalSympathiesReceived)")
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}