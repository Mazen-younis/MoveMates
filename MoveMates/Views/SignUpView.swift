import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var errorMessage: String?
    @State private var navigateToSetupProfile = false

    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        Text("Create an Account")
                            .screenTitleStyle()
                            .multilineTextAlignment(.center)

                        labeledTextField("Name", text: $name, placeholder: "Your name")
                        labeledTextField("Username", text: $username, placeholder: "Choose a username")
                        labeledTextField("Email", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
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
                                Button { showPassword.toggle() } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.aquaBlue)
                                }
                            }
                            .padding()
                            .background(Color.charcoalGray)
                            .cornerRadius(10)
                            .foregroundColor(.pureWhite)
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .foregroundColor(.coolGray)
                                .font(.headline)

                            HStack {
                                Group {
                                    if showConfirmPassword {
                                        TextField("", text: $confirmPassword, prompt: Text("Re-enter your password").foregroundColor(.pureWhite.opacity(0.6)))
                                    } else {
                                        SecureField("", text: $confirmPassword, prompt: Text("Re-enter your password").foregroundColor(.pureWhite.opacity(0.6)))
                                    }
                                }
                                Button { showConfirmPassword.toggle() } label: {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.aquaBlue)
                                }
                            }
                            .padding()
                            .background(Color.charcoalGray)
                            .cornerRadius(10)
                            .foregroundColor(.pureWhite)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }

                        Button(action: registerUser) {
                            Text("Sign Up")
                                .moveMatesButtonStyle()
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToSetupProfile) {
                SetupProfileView()
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

    private func labeledTextField(_ label: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .foregroundColor(.coolGray)
                .font(.headline)

            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.pureWhite.opacity(0.6)))
                .padding()
                .background(Color.charcoalGray)
                .cornerRadius(10)
                .foregroundColor(.pureWhite)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
    }

    private func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        errorMessage = nil

        let newUser = UserCreateRequest(
            name: name,
            username: username,
            email: email,
            password: password,
            skill_level: "",
            sports: []
        )

        APIService.shared.registerUser(user: newUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdUser):
                    // 🌟 Update the SessionManager explicitly for a brand new user
                    sessionManager.currentUser = createdUser
                    sessionManager.didSignUp = true // Tell SessionManager this is a new user!
                    sessionManager.hasCompletedProfile = false
                    sessionManager.authState = .needsProfile
                    navigateToSetupProfile = true

                case .failure(let error):
                    errorMessage = "Sign-up failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(SessionManager.shared)
}
