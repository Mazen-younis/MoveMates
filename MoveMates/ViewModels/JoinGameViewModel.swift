//
//  JoinGameViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 05/06/2025.
//
import Foundation
import SwiftUI

class JoinGameViewModel: ObservableObject {
    @Published var joinRequestAlreadyExists: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func checkAndRequestJoin(userId: Int, gameId: Int) {
        // Step 1: Fetch join requests for this user (filter locally by gameId)
        APIService.shared.fetchJoinRequestsForUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    // Check if this game already has a request by the user
                    if requests.contains(where: { $0.game_id == gameId }) {
                        self?.joinRequestAlreadyExists = true
                        self?.alertMessage = "You have already requested to join this game."
                        self?.showAlert = true
                    } else {
                        // Step 2: Actually send the join request
                        self?.sendJoinRequest(userId: userId, gameId: gameId)
                    }
                case .failure(let error):
                    self?.alertMessage = "Failed to check existing requests: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }

    private func sendJoinRequest(userId: Int, gameId: Int) {
        self.isSubmitting = true
        APIService.shared.requestToJoinGame(userId: userId, gameId: gameId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                switch result {
                case .success:
                    self?.alertMessage = "Join request sent successfully!"
                    self?.showAlert = true
                case .failure(let error):
                    self?.alertMessage = "Failed to send join request: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }
}
