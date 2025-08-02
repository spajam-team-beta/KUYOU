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
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label("供養の広場", systemImage: "hands.sparkles")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "person.circle")
                }
                .tag(1)
        }
        .accentColor(.purple)
    }
}

#Preview {
    ContentView()
}
