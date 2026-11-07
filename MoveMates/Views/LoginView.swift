import SwiftUI

struct LoginView: View {
    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showPassword = false
    @State private var errorMessage: String?

    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $sessionManager.navigationPath) {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Welcome Back")
                        .screenTitleStyle()
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email or Username")
                            .foregroundColor(.coolGray)
                            .font(.headline)

                        TextField("", text: $emailOrUsername, prompt: Text("Enter your email or username").foregroundColor(.pureWhite.opacity(0.6)))
                            .padding()
                            .background(Color.charcoalGray)
                            .cornerRadius(12)
                            .foregroundColor(.pureWhite)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .foregroundColor(.coolGray)
                            .font(.headline)

                        HStack {
                            Group {
                                if showPassword {
                                    TextField("", text: $password, prompt: Text("Enter your password").foregroundColor(.pureWhite.opacity(0.6)))
                                } else {
                                    SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.pureWhite.opacity(0.6)))
                                }
                            }
                            .foregroundColor(.pureWhite)

                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.aquaBlue)
                            }
                        }
                        .padding()
                        .background(Color.charcoalGray)
                        .cornerRadius(12)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    Button(action: loginUser) {
                        Text("Log In")
                            .moveMatesButtonStyle()
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color.jetBlack.ignoresSafeArea())
            .navigationDestination(isPresented: $isLoggedIn) {
                if sessionManager.hasCompletedProfile {
                    HomePageView()
                } else {
                    SetupProfileView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Welcome")
                        }
                        .foregroundColor(.aquaBlue)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func loginUser() {
        errorMessage = nil

        APIService.shared.loginUser(identifier: emailOrUsername, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    sessionManager.currentUser = user
                    sessionManager.hasCompletedProfile = user.hasCompletedProfile
                    sessionManager.isLoggedIn = true
                    isLoggedIn = true
                case .failure:
                    errorMessage = "Invalid email or password"
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager.shared)
}
