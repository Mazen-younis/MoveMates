//
//  PrivateChatListViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import Foundation

class PrivateChatListViewModel: ObservableObject {
    @Published var privateChats: [PrivateChatSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchPrivateChats(for userId: Int) {
        isLoading = true
        APIService.shared.fetchPrivateChats(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let chats):
                    self.privateChats = chats
                case .failure(let error):
                    self.errorMessage = "Failed to load private chats: \(error.localizedDescription)"
                }
            }
        }
    }

    func deleteChat(chatId: Int) {
        privateChats.removeAll { $0.id == chatId }

        // Find current userId (maybe through SessionManager.shared.currentUser?.id)
        guard let currentUserId = SessionManager.shared.currentUser?.id else {
            print("Current user ID not found.")
            return
        }

        APIService.shared.deletePrivateChat(currentUserId: currentUserId, recipientId: chatId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Chat deleted successfully from backend.")
                case .failure(let error):
                    print("Failed to delete chat from backend: \(error.localizedDescription)")
                    // Optionally: reload from server to get consistent state
                    // Or show an error message to user
                }
            }
        }
    }
}
