//
//  RequestListViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 20/05/2025.
//

import Foundation

class RequestListViewModel: ObservableObject {
    @Published var joinRequests: [JoinRequest] = []
    @Published var allUsers: [MoveMatesUser] = []

    func loadGamesAndRequests(currentUserId: Int) {
        APIService.shared.fetchJoinRequestsForUser(userId: currentUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    self?.joinRequests = requests
                case .failure(let error):
                    print("Failed to load requests: \(error)")
                }
            }
        }
    }

    func loadAllUsers() {
        APIService.shared.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.allUsers = users
                case .failure(let error):
                    print("Failed to load users: \(error)")
                }
            }
        }
    }

    func approveRequest(requestId: Int, gameId: Int) {
        APIService.shared.approveJoinRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.joinRequests.removeAll { $0.id == requestId }
                case .failure(let error):
                    print("Approval failed: \(error)")
                }
            }
        }
    }

    func reject(requestId: Int) {
        joinRequests.removeAll { $0.id == requestId }
    }
}
