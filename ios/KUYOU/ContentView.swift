//
//  ContentView.swift
//  KUYOU
//
//  Created by saki on 2025/08/02.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        if authService.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    @StateObject private var timelineViewModel = TimelineViewModel()
    
    var body: some View {
        TabView {
            Tab("供養の広場", systemImage: "hands.sparkles") {
                TimelineView(viewModel: timelineViewModel)
            }
            
            Tab("プロフィール", systemImage: "person.circle") {
                ProfileView()
            }
            
            Tab(role: .search) {
                TimelineView(viewModel: timelineViewModel)
            }
        }
        .accentColor(.purple)
        .searchable(
            text: $timelineViewModel.searchText,
            prompt: "黒歴史を検索..."
        )
    }
}

#Preview {
    ContentView()
}
