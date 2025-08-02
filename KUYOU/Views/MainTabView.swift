import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label("供養の広場", systemImage: "list.bullet.rectangle")
                }
                .tag(0)
            
            PostView()
                .tabItem {
                    Label("懺悔の間", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}