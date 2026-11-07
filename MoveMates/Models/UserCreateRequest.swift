//
//  PrivateChatSummary.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//


import Foundation

struct UserCreateRequest: Codable {
    let name: String
    let username: String
    let email: String
    let password: String
    let skill_level: String?
    let sports: [String]?
}
