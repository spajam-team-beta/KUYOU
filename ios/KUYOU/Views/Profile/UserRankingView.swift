import SwiftUI
import Combine

struct RankingResponse: Decodable {
    let ranking: [RankingUser]
}

struct RankingUser: Decodable {
    let rank: Int
    let id: Int
    let email: String
    let totalPoints: Int
    
    enum CodingKeys: String, CodingKey {
        case rank, id, email
        case totalPoints = "total_points"
    }
}

struct UserRankingView: View {
    @State private var rankings: [RankingItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    
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
            responseType: RankingResponse.self
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
                rankings = response.ranking.map { user in
                    RankingItem(
                        rank: user.rank,
                        userId: user.id,
                        email: user.email,
                        totalPoints: user.totalPoints
                    )
                }
            }
        )
        .store(in: &cancellables)
    }
}