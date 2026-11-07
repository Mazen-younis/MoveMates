//
//  MoveMatesApp.swift
//  MoveMates
//
//  Created by Mazen Younis on 25/04/2025.
//
import SwiftUI

@main
struct MoveMatesApp: App {
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var locationManager = LocationManager()

    init() {
        // Global NavigationBar styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = nil  // Optional: removes the shadow line

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor.systemTeal  // Matches your .aquaBlue

        // Optional: adjust status bar style
        // UINavigationBar.appearance().barStyle = .black
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch sessionManager.authState {
                case .loggedOut:
                    WelcomeView()
                case .needsProfile:
                    SetupProfileView()
                case .loggedIn:
                    HomePageView()
                }
            }
            .environmentObject(sessionManager)
            .environmentObject(locationManager)
        }
    }
}
