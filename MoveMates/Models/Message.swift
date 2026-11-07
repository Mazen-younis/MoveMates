//
//  Message.swift
//  MoveMates
//
//  Created by Mazen Younis on 16/05/2025.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: Int
    let content: String
    let game_id: Int?
    let recipient_id: Int?
    let sender_id: Int
    let timestamp: String
    let read: Bool
}

extension Message {
    var formattedTimestamp: String {
        print("Actual timestamp: \(timestamp)")

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: timestamp) {
            return DateFormatter.messageTimeFormatter.string(from: date)
        }

        // Add a variant that handles timestamps without fractional seconds and with 'Z' timezone
        isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        if let date = isoFormatter.date(from: timestamp) {
            return DateFormatter.messageTimeFormatter.string(from: date)
        }

        // Use a fallback DateFormatter
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = fallbackFormatter.date(from: timestamp) {
            return DateFormatter.messageTimeFormatter.string(from: date)
        }

        return "—"
    }
}


