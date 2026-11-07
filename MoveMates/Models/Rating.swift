//
//  Rating.swift
//  MoveMates
//
//  Created by Mazen Younis on 05/06/2025.
//

import Foundation

struct Rating: Identifiable, Codable {
    let id: Int
    let fromId: Int
    let fromName: String
    let toId: Int
    let toName: String
    let rating: Double
    let feedback: String?
    let date: String // ISO8601 format

    var dateObject: Date? {
        ISO8601DateFormatter().date(from: date)
    }
}
