//
//  MyEventsViewModel.swift
//  MoveMates
//
//  Created by Mazen Younis on 27/05/2025.
//

import Foundation
import Combine

class MyEventsViewModel: ObservableObject {
    @Published var myGames: [Game] = []
    @Published var participants: [Int: [MoveMatesUser]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Sorted from newest to oldest
    var sortedMyGames: [Game] {
        myGames.sorted {
            let date1 = $0.date.parsedISODate()
            let date2 = $1.date.parsedISODate()
            if date1 == nil || date2 == nil {
                print("Couldn’t parse date(s): \($0.date), \($1.date)")
            }
            return (date1 ?? .distantPast) > (date2 ?? .distantPast)
        }
    }

    func fetchMyGames(userId: Int) {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchGamesCreatedBy(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let games):
                    self.myGames = games
                    self.fetchParticipants(for: games)
                case .failure(let error):
                    self.errorMessage = "Failed to load events: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchParticipants(for games: [Game]) {
        for game in games {
            APIService.shared.getParticipants(for: game.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let users):
                        self.participants[game.id] = users
                    case .failure:
                        self.participants[game.id] = []
                    }
                }
            }
        }
    }
}
