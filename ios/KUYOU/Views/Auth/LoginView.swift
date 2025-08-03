import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    private let placeholderEmail = "email@example.com"
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(stops: [.init(color: .lightBlue, location: 0.1), .init(color: .russet, location: 1.0)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    // Logo and Title
                    VStack(spacing: 10) {
                        Image.kuyouIcon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .foregroundColor(.purple)
                        
                        Text("KUYOU")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("黒歴史供養プラットフォーム")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メールアドレス")
                                .font(.caption)
                                .foregroundColor(.black)
                            
                            TextField(placeholderEmail, text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("パスワード")
                                .font(.caption)
                                .foregroundColor(.black)
                            
                            SecureField("6文字以上", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Password confirmation (for registration)
                        if viewModel.isShowingRegistration {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード（確認）")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                
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
                        .padding(.top, 30)
                        .padding(.bottom, 60)
                        .disabled(viewModel.isShowingRegistration ? !viewModel.canRegister : !viewModel.canLogin)
                        
                        // Toggle auth mode
                        
                        Button(action: {
                            viewModel.toggleAuthMode()
                        }) {
                            Text(viewModel.isShowingRegistration
                                 ? "すでにアカウントをお持ちの方はこちら"
                                 : "アカウントをお持ちでない方はこちら")
                            .font(.caption)
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 50)
                    
                    Spacer()
                    
                    
                        .navigationBarHidden(true)
                }
            }
        }
    }
}
