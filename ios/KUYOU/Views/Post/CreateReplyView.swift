import SwiftUI
import Combine

struct CreateReplyView: View {
    let postId: Int
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    
    var canSubmit: Bool {
        !content.isEmpty && content.count <= 500 && !isLoading
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("智慧の泉")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("より良い対応方法を提案しましょう")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Content input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("リライト案")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(content.count)/500")
                            .font(.caption2)
                            .foregroundColor(content.count > 400 ? .orange : .secondary)
                    }
                    
                    TextEditor(text: $content)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    Text("こうすれば良かったかも...\nこう考えてみては...")
                                        .font(.body)
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(12)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // Notice
                VStack(alignment: .leading, spacing: 4) {
                    Label("投稿時の注意", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("• 建設的なアドバイスを心がけましょう\n• リライト案を投稿すると5ポイントの徳が積まれます\n• ベストアンサーに選ばれると30ポイント獲得")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitReply) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("投稿")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }
    
    private func submitReply() {
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        
        ReplyService.shared.createReply(postId: postId, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    onSuccess()
                    dismiss()
                }
            )
            .store(in: &cancellables)
    }
}