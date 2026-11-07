//
//  ContentView.swift
//  MoveMates
//
//  Created by Mazen Younis on 25/04/2025.


import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = SessionManager.shared

    var body: some View {
        NavigationStack {
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
            .background(Color.jetBlack.ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
}

