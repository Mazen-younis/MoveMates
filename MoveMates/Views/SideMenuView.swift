import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isMenuOpen: Bool
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Close Menu Button
            Button {
                withAnimation { isMenuOpen = false }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.pureWhite)
                    .padding(.top, 20)
            }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    if let currentUser = sessionManager.currentUser {
                        navigateToProfile(user: currentUser)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sessionManager.currentUser?.name ?? "Welcome")
                            .font(.title.bold())
                            .foregroundColor(.pureWhite)
                        Text("@\(sessionManager.currentUser?.username ?? "")")
                            .font(.caption)
                            .foregroundColor(.coolGray)
                    }
                }
                .buttonStyle(PlainButtonStyle()) // remove default tap styling
            }

            Divider().background(Color.coolGray)

            // Main Menu Items
            VStack(alignment: .leading, spacing: 18) {

                menuItem(title: "Edit Profile", systemImage: "pencil") {
                    navigate(to: .editProfile)
                }
                menuItem(title: "My Events", systemImage: "calendar") {
                    navigate(to: .myEvents)
                }
                menuItem(title: "Ratings", systemImage: "star") {
                    navigate(to: .ratings)
                }
            }

            Spacer()

            // Bottom Menu Items
            VStack(alignment: .leading, spacing: 18) {
                menuItem(title: "Help & Support", systemImage: "questionmark.circle") {
                    navigate(to: .helpSupport)
                }
                menuItem(title: "Terms & Privacy", systemImage: "doc.text") {
                    navigate(to: .termsPrivacy)
                }
                menuItem(title: "Log Out", systemImage: "arrow.backward.square") {
                    withAnimation { isMenuOpen = false }
                    sessionManager.logOut()
                }
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.charcoalGray)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 4, y: 0)
    }

    // MARK: - Navigation to targets
    private func navigate(to target: HomePageView.NavigationTarget) {
        withAnimation { isMenuOpen = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("Navigating to \(target)")
            navigationPath.append(target)
        }
    }

    // MARK: - Navigate to own UserProfileView
    private func navigateToProfile(user: MoveMatesUser) {
        withAnimation { isMenuOpen = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("Navigating to UserProfileView for user: \(user.username)")
            navigationPath.append(HomePageView.NavigationTarget.userProfile(user: user))
        }
    }

    // MARK: - Menu Item
    @ViewBuilder
    private func menuItem(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.aquaBlue)
                Text(title)
                    .foregroundColor(.pureWhite)
                    .font(.body)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    SideMenuView(
        isMenuOpen: .constant(true),
        navigationPath: .constant(NavigationPath())
    )
    .environmentObject(SessionManager())
}
