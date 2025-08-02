import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("KUYOU")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("黒歴史供養プラットフォーム")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Form
                VStack(spacing: 16) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メールアドレス")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("email@example.com", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("パスワード")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        SecureField("6文字以上", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Password confirmation (for registration)
                    if viewModel.isShowingRegistration {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("パスワード（確認）")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SecureField("パスワードを再入力", text: $viewModel.passwordConfirmation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Submit button
                    Button(action: {
                        if viewModel.isShowingRegistration {
                            viewModel.register()
                        } else {
                            viewModel.login()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isShowingRegistration ? "登録する" : "ログイン")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (viewModel.isShowingRegistration ? viewModel.canRegister : viewModel.canLogin)
                                ? Color.purple
                                : Color.gray
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.isShowingRegistration ? !viewModel.canRegister : !viewModel.canLogin)
                    
                    // Toggle auth mode
                    Button(action: {
                        viewModel.toggleAuthMode()
                    }) {
                        Text(viewModel.isShowingRegistration
                            ? "すでにアカウントをお持ちの方はこちら"
                            : "アカウントをお持ちでない方はこちら")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                Text("あなたの黒歴史を供養しましょう")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}