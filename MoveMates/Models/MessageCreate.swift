//
//  MessageCreate.swift
//  MoveMates
//
//  Created by Mazen Younis on 16/05/2025.
//

import Foundation

struct MessageCreate: Codable {
    let content: String
    let game_id: Int?
    let recipient_id: Int
    let sender_id: Int
}

