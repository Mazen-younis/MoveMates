//
//  CreateGameViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 09/05/2025.
//

import Foundation
import SwiftUI

class CreateGameViewModel: ObservableObject {
    @Published var sport: String = ""
    @Published var location: String = ""
    @Published var date: Date = Date()
    @Published var neededPlayers: String = ""
    @Published var skillLevel: String = "Beginner"
    @Published var genderPreference: String = "Any"
    @Published var isPublic: Bool = true
    @Published var isSubmitting: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var createdGameId: Int? = nil
    @Published var navigateToJoinGame: Bool = false
    @Published var showDatePicker = false
    @Published var showTimePicker = false
    
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    var formattedISODate: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current // Local time with timezone info
        return formatter.string(from: date)
    }

    let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    let genders = ["Any", "Male", "Female"]

    func createGame(currentUser: MoveMatesUser, completion: @escaping () -> Void) {
        guard let neededPlayersInt = Int(neededPlayers) else {
            alertMessage = "Please enter a valid number of needed players."
            showAlert = true
            return
        }

        guard let creatorId = currentUser.id else {
            alertMessage = "User ID missing."
            showAlert = true
            return
        }

        isSubmitting = true

        let game = GameCreateRequest(
            sport: sport,
            location: location,
            date: formattedISODate,
            needed_players: neededPlayersInt,
            skill_level: skillLevel,
            gender_preference: genderPreference,
            is_public: isPublic,
            creator_id: creatorId
        )

        APIService.shared.createGame(game: game) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                switch result {
                case .success(let gameId):
                    self?.alertMessage = "Game created successfully!"
                    self?.createdGameId = gameId
                    self?.navigateToJoinGame = true
                    self?.showAlert = true
                    completion()
                case .failure(let error):
                    self?.alertMessage = "Failed to create game: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }
}
