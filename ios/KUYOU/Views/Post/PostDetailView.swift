import SwiftUI

struct PostDetailView: View {
    let postId: Int
    @StateObject private var viewModel = PostDetailViewModel()
    @State private var showingReplySheet = false
 
    @State private var isPressed = false
    @State private var showGlow = false
    @State private var particleEmit = false
    @State private var animateAscension = false
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("読み込み中...")
                    .padding()
            } else if let post = viewModel.post {
                VStack(alignment: .leading, spacing: 20) {
                    // Post content
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.nickname)
                                    .font(.headline)
                                
                                Text(formatDate(post.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            CategoryBadge(category: post.category)
                        }
                        
                        // Content
                        Text(post.content)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Status
                        if post.isResolved {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("この投稿は成仏しました")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Actions
                        HStack(spacing: 30) {
                            // Sympathy button with animation
                            ZStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        isPressed = true
                                        showGlow = true
                                        particleEmit = true
                                    }
                                    
                                    AudioService.shared.playMokugyo()
                                    viewModel.toggleSympathy()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isPressed = false
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        showGlow = false
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "hands.sparkles.fill")
                                            .font(.body)
                                        Text("\(post.sympathyCount)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Circle()
                                            .fill(Color.purple.opacity(0.1))
                                    )
                                }
                                .mokugyoTap(isPressed: $isPressed)
                                .salvationGlow(trigger: $showGlow)
                                .disabled(!AuthService.shared.isAuthenticated)
                                .overlay(
                                    GeometryReader { geometry in
                                        ParticleEmitterView(emit: $particleEmit)
                                            .position(
                                                x: geometry.size.width / 2,
                                                y: geometry.size.height / 2
                                            )
                                            .allowsHitTesting(false)
                                    }
                                )
                            }
                            
                            // Reply button
                            if !post.isResolved {
                                Button(action: {
                                    showingReplySheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bubble.left")
                                        Text("リライト案を投稿")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                                .disabled(!AuthService.shared.isAuthenticated)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Replies section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("智慧の泉 (\(viewModel.replies.count)件)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.replies.isEmpty {
                            Text("まだリライト案がありません")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(viewModel.replies) { reply in
                                ReplyCard(
                                    reply: reply,
                                    isPostOwner: post.isMine ?? false,
                                    onSelectBest: {
                                        viewModel.selectBestReply(reply)
                                        if !post.isResolved {
                                            viewModel.showAscensionEffect = true
                                            AudioService.shared.playAscension()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                viewModel.showAscensionEffect = false
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("投稿詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReplySheet) {
            CreateReplyView(postId: postId) {
                viewModel.loadReplies()
            }
        }
        .onAppear {
            viewModel.postId = postId
            viewModel.loadPost()
        }
        .overlay(
            ascensionOverlay
        )
    }
    
    @ViewBuilder
    private var ascensionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .opacity(viewModel.showAscensionEffect ? 1 : 0)
            
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkles")
                    .font(.system(size: 30 + CGFloat(index * 10)))
                    .foregroundColor(.yellow.opacity(0.8))
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 100,
                        y: sin(Double(index) * .pi / 4) * 100
                    )
                    .rotationEffect(.degrees(animateAscension ? 360 * Double(index + 1) : 0))
                    .scaleEffect(animateAscension ? 1.5 : 0.5)
                    .opacity(animateAscension ? 0.8 : 0)
                    .animation(.easeInOut(duration: 2).delay(Double(index) * 0.1), value: animateAscension)
            }
            
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .scaleEffect(animateAscension ? 2 : 0)
                        .opacity(animateAscension ? 0 : 1)
                        .animation(.easeOut(duration: 1.5), value: animateAscension)
                    
                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(animateAscension ? 720 : 0))
                        .scaleEffect(animateAscension ? 1.2 : 0.3)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateAscension)
                }
                
                VStack(spacing: 16) {
                    Text("🙏 成仏 🙏")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 10)
                        .scaleEffect(animateAscension ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animateAscension)
                    
                    Text("黒歴史が浄化されました")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(animateAscension ? 1 : 0)
                        .offset(y: animateAscension ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateAscension)
                    
                    Text("+80 徳ポイント")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(20)
                        .opacity(animateAscension ? 1 : 0)
                        .offset(y: animateAscension ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(1.2), value: animateAscension)
                }
            }
        }
        .allowsHitTesting(viewModel.showAscensionEffect)
        .opacity(viewModel.showAscensionEffect ? 1 : 0)
        .animation(.easeInOut, value: viewModel.showAscensionEffect)
        .onTapGesture {
            animateAscension = false
            viewModel.showAscensionEffect = false
        }
        .onChange(of: viewModel.showAscensionEffect) { newValue in
            if newValue {
                animateAscension = false
                DispatchQueue.main.async {
                    animateAscension = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    animateAscension = false
                    viewModel.showAscensionEffect = false
                }
            }
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

