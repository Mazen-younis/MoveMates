//
//  JoinRequest.swift
//  MoveMates
//
//  Created by Mazen Younis on 16/05/2025.
//

import Foundation

struct JoinRequest: Identifiable, Codable {
    let id: Int
    let user_id: Int
    let username: String? 
    let game_id: Int
    let status: String
    let created_at: String
    let game_sport: String?
    let game_location: String?
}
