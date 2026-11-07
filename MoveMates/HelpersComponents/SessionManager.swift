import Foundation
import SwiftUI

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    enum AuthState {
        case loggedOut
        case needsProfile
        case loggedIn
    }
    
    @Published var hasCompletedProfile: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var didSignUp: Bool = false
    @Published var authState: AuthState = .loggedOut
    
    @Published var currentUser: MoveMatesUser? {
        didSet {
            if let user = currentUser {
                saveUserToDefaults(user)
                isLoggedIn = true
                // REMOVE auto fallback to needsProfile
                hasCompletedProfile = user.hasCompletedProfile
                authState = .loggedIn // always logged in if user exists
            } else {
                removeUserFromDefaults()
                isLoggedIn = false
                hasCompletedProfile = false
                authState = .loggedOut
            }
        }
    }

    // Navigation Path persistence
    @Published var navigationPath = NavigationPath()
    
    init() {
        loadUserFromDefaults()
    }
    
    private func saveUserToDefaults(_ user: MoveMatesUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
    }
    
    private func loadUserFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(MoveMatesUser.self, from: data) {
            self.currentUser = user
        }
    }
    
    private func removeUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func logOut() {
        currentUser = nil
        navigationPath.removeLast(navigationPath.count)
    }
}
