import SwiftUI

struct UserRankingView: View {
    @State private var rankings: [RankingItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    struct RankingItem: Identifiable {
        let id = UUID()
        let rank: Int
        let userId: Int
        let email: String
        let totalPoints: Int
    }
    
    var body: some View {
        List {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("読み込み中...")
                    Spacer()
                }
                .padding()
            } else if rankings.isEmpty {
                Text("ランキングデータがありません")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(rankings) { item in
                    HStack(spacing: 16) {
                        // Rank
                        ZStack {
                            Circle()
                                .fill(rankColor(for: item.rank))
                                .frame(width: 40, height: 40)
                            
                            Text("\(item.rank)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        // User info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.email)
                                .font(.headline)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text("\(item.totalPoints) 徳ポイント")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Medal for top 3
                        if item.rank <= 3 {
                            Image(systemName: medalIcon(for: item.rank))
                                .font(.title2)
                                .foregroundColor(medalColor(for: item.rank))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("徳ポイントランキング")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadRankings()
        }
    }
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .purple
        }
    }
    
    private func medalIcon(for rank: Int) -> String {
        switch rank {
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
    
    private func medalColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    private func loadRankings() {
        APIService.shared.request(
            path: "/users/ranking",
            method: "GET",
            responseType: [String: [[String: Any]]].self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                }
            },
            receiveValue: { response in
                if let rankingData = response["ranking"] {
                    rankings = rankingData.compactMap { item in
                        guard let rank = item["rank"] as? Int,
                              let id = item["id"] as? Int,
                              let email = item["email"] as? String,
                              let totalPoints = item["total_points"] as? Int else {
                            return nil
                        }
                        return RankingItem(
                            rank: rank,
                            userId: id,
                            email: email,
                            totalPoints: totalPoints
                        )
                    }
                }
            }
        )
        .store(in: &Set<AnyCancellable>())
    }
}