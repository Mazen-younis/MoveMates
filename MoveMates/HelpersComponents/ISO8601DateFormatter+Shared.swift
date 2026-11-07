//
//  ISO8601DateFormatter+Shared.swift
//  MoveMates
//
//  Created by Mazen Younis on 04/06/2025.
//

import Foundation

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
