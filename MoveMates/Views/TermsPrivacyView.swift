//
//  TermsPrivacyView.swift
//  MoveMates
//
//  Created by Mazen Younis on 26/05/2025.
//

import SwiftUI

struct TermsPrivacyView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Terms & Privacy Policy")
                    .screenTitleStyle()
                    .font(.title.bold())
                    .foregroundColor(.pureWhite)

                Group {
                    Text("1. Your Data")
                        .font(.headline)
                        .foregroundColor(.aquaBlue)
                    Text("We only collect the information you provide to us when signing up and using the app, such as your name, sport preferences, and location. Your data is stored securely and never shared without your consent.")
                        .foregroundColor(.coolGray)

                    Text("2. How We Use It")
                        .font(.headline)
                        .foregroundColor(.aquaBlue)
                    Text("We use your information to match you with compatible sports partners and suggest relevant events. We do not sell or rent your data to third parties.")
                        .foregroundColor(.coolGray)

                    Text("3. Community Guidelines")
                        .font(.headline)
                        .foregroundColor(.aquaBlue)
                    Text("Be respectful to others. Offensive, discriminatory, or aggressive behavior will result in account suspension.")
                        .foregroundColor(.coolGray)

                    Text("4. Account Removal")
                        .font(.headline)
                        .foregroundColor(.aquaBlue)
                    Text("You can request your account and all associated data to be deleted at any time by contacting our support team.")
                        .foregroundColor(.coolGray)

                    Text("5. Updates")
                        .font(.headline)
                        .foregroundColor(.aquaBlue)
                    Text("We may update these terms to reflect changes in our services or legal requirements. We'll notify you of any significant changes.")
                        .foregroundColor(.coolGray)
                }

                Divider().background(Color.coolGray)

                Text("By continuing to use MoveMates, you agree to these terms.")
                    .font(.footnote)
                    .foregroundColor(.coolGray)
                    .padding(.top)
            }
            .padding()
        }
        .background(Color.jetBlack.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    sessionManager.navigationPath.removeLast(sessionManager.navigationPath.count)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                    .foregroundColor(.aquaBlue)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        TermsPrivacyView()
            .environmentObject(SessionManager())
    }
}
