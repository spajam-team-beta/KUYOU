//
//  KUYOUApp.swift
//  KUYOU
//
//  Created by saki on 2025/08/02.
//

import SwiftUI

@main
struct KUYOUApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Auto-login for testing
                    if !AuthService.shared.isAuthenticated {
                        AuthService.shared.loginAsDemoUser()
                    }
                }
        }
    }
}
