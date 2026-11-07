//
//  HelpSupportView.swift
//  MoveMates
//
//  Created by Mazen Younis on 26/05/2025.
//

import SwiftUI

struct HelpSupportView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            Color.jetBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Help & Support")
                    .screenTitleStyle()
                    .foregroundColor(.pureWhite)

                Text("We're here to help!")
                    .font(.headline)
                    .foregroundColor(.aquaBlue)

                Text("If you have any questions or concerns, please reach out to our support team at:")
                    .foregroundColor(.coolGray)

                HStack(spacing: 8) {
                    Image(systemName: "envelope")
                        .foregroundColor(.aquaBlue)
                    Text("support@movemates.com")
                        .foregroundColor(.pureWhite)
                        .underline()
                }

                Divider().background(Color.coolGray)

                Text("You can also check our FAQ and community guidelines for common questions and tips.")
                    .foregroundColor(.coolGray)

                Spacer()
            }
            .padding()
        }
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
        HelpSupportView()
            .environmentObject(SessionManager())
    }
}
