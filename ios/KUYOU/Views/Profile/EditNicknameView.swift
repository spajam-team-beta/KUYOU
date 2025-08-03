import SwiftUI
import Combine

struct EditNicknameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditNicknameViewModel()
    @State private var nickname: String
    
    let currentNickname: String?
    let onSave: (String) -> Void
    
    init(currentNickname: String?, onSave: @escaping (String) -> Void) {
        self.currentNickname = currentNickname
        self.onSave = onSave
        self._nickname = State(initialValue: currentNickname ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ニックネーム")
                        .font(.headline)
                    
                    TextField("ニックネーム（30文字以内）", text: $nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onReceive(Just(nickname)) { _ in
                            if nickname.count > 30 {
                                nickname = String(nickname.prefix(30))
                            }
                        }
                    
                    HStack {
                        Text("\(nickname.count)/30")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if nickname.isEmpty {
                            Text("デフォルトニックネームが使用されます")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("プレビュー")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ランキング表示、リライト表示:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(nickname.isEmpty ? "智者#0001" : nickname)
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("ニックネーム設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.updateNickname(nickname) { success in
                            if success {
                                onSave(nickname)
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

class EditNicknameViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func updateNickname(_ nickname: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        print("🔄 ニックネーム更新開始: '\(nickname)'")
        
        let request = UpdateNicknameRequest(user: UpdateNicknameRequest.UserData(nickname: nickname))
        
        guard let body = try? APIService.shared.encode(request) else {
            print("❌ リクエストエンコード失敗")
            errorMessage = "リクエストの作成に失敗しました"
            isLoading = false
            completion(false)
            return
        }
        
        print("📤 APIリクエスト送信中...")
        
        APIService.shared.request(
            path: "/profile",
            method: "PATCH",
            body: body,
            authenticated: true,
            responseType: UpdateNicknameResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    print("❌ API呼び出し失敗: \(error)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    print("✅ API呼び出し完了")
                }
            },
            receiveValue: { response in
                print("📨 レスポンス受信: \(response)")
                print("💾 ニックネーム更新成功!")
                completion(true)
            }
        )
        .store(in: &cancellables)
    }
}

struct UpdateNicknameRequest: Codable {
    let user: UserData
    
    struct UserData: Codable {
        let nickname: String
    }
}

struct UpdateNicknameResponse: Codable {
    let user: User
}
