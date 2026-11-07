//
//  PrivateChatViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import Foundation
import Combine

class PrivateChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    let senderId: Int
    let recipientId: Int

    private var didMarkUnreadOnce = false

    init(senderId: Int, recipientId: Int) {
        self.senderId = senderId
        self.recipientId = recipientId
        fetchMessages()
    }

    func fetchMessages() {
        isLoading = messages.isEmpty // show spinner only when chat is empty
        errorMessage = nil

        guard let url = URL(string: "\(APIService.shared.baseURL)/private_messages/\(senderId)/\(recipientId)") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data"
                    return
                }

                do {
                    let decodedMessages = try JSONDecoder().decode([Message].self, from: data)
                    self.messages = decodedMessages

                    // Only mark unread messages as read once
                    if !self.didMarkUnreadOnce {
                        self.didMarkUnreadOnce = true
                        self.markUnreadMessagesAsReadOnce()
                    }

                } catch {
                    self.errorMessage = "Decode error: \(error)"
                }
            }
        }.resume()
    }

    func sendMessage() {
        let payload = MessageCreate(
            content: newMessageText,
            game_id: nil,
            recipient_id: recipientId,
            sender_id: senderId
        )

        APIService.shared.sendPrivateMessage(message: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.newMessageText = ""
                    self.fetchMessages() // reload from backend instead of appending to avoid duplicates
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func markUnreadMessagesAsReadOnce() {
        let unreadMessages = messages.filter { !$0.read && $0.recipient_id == senderId }
        for message in unreadMessages {
            APIService.shared.markPrivateMessageAsRead(messageId: message.id) { _ in }
        }
    }
}
