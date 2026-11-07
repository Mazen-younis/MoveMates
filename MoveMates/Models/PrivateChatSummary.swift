//
//  PrivateChatSummary.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import Foundation

struct PrivateChatSummary: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let lastMessage: String
    let timestamp: String
    let profile_picture_url: String?
}

