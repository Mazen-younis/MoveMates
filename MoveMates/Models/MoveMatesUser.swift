//
//  PrivateChatSummary.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import Foundation

struct MoveMatesUser: Codable, Hashable, Identifiable {
    var id: Int?
    var name: String
    var username: String
    var email: String
    var skill_level: String?
    var sports: [String]?
    var bio: String?
    var gender: String?
    var preferred_sports_partner: String?
    var favorite_times_to_play: [String]?
    var phone_number: String?
    var notifications_enabled: Bool?
    var profile_picture_url: String?
    var date_of_birth: String?
    var location: String?
    var created_at: String
    var lastMessage: String?
    var timestamp: String?
    

    var hasCompletedProfile: Bool {
        let hasBio = !(bio?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasGender = !(gender?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasSports = !(sports?.isEmpty ?? true)
        let hasLocation = !(location?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)

        return hasBio && hasGender && hasSports && hasLocation
    }
}
