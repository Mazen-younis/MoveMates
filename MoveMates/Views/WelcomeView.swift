import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                VStack(spacing: 24) { // Reduced spacing to shift up
                    Spacer(minLength: 40) // Less spacing at top to shift content upwards

                    Image("welcome_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)

                    Text("Welcome to MoveMates")
                        .screenTitleStyle()
                        .multilineTextAlignment(.center)

                    Text("Your place to find a MoveMate nearby.")
                        .font(.title3)
                        .foregroundColor(.coolGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer() // Keep space, but it’s smaller now to bring everything up

                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Text("Get Started")
                            Image(systemName: "arrow.right")
                        }
                        .moveMatesButtonStyle()
                        .padding(.horizontal, 40)
                    }

                    // Additional prompt before sign up
                    VStack(spacing: 4) {
                        Text("Don't have an account yet?")
                            .foregroundColor(.coolGray)

                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .foregroundColor(.aquaBlue)
                                .underline()
                        }
                    }
                    .font(.footnote)

                    Spacer(minLength: 20) // Additional bottom padding
                }
                .padding(.horizontal, 24) // Add horizontal padding for better alignment
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(SessionManager())
}
