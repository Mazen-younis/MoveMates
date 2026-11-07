//
//  GameCreateRequest.swift
//  SpotMe
//
//  Created by Mazen Younis on 09/05/2025.
//

import Foundation

struct GameCreateRequest: Codable {
    let sport: String
    let location: String
    let date: String
    let needed_players: Int
    let skill_level: String
    let gender_preference: String
    let is_public: Bool
    let creator_id: Int
}

