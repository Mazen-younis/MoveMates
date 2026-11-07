//
//  DateFormatter+Chat.swift
//  MoveMates
//
//  Created by Mazen Younis on 26/05/2025.
//

import Foundation

extension DateFormatter {
    /// App-wide formatter (for events etc.)
    static let chatTimestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter
    }()

    /// Dedicated time-only formatter for message bubbles
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Hour and minute only
        return formatter
    }()

    /// Display formatter for events (local time zone)
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
    
}

extension String {
    func formattedDate() -> String {
        let isoFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        for format in isoFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) {
                let display = DateFormatter()
                display.dateFormat = "dd MMMM yyyy, HH:mm"
                display.locale = Locale.current
                display.timeZone = .current
                return display.string(from: date)
            }
        }

        // Fallback: just show the raw string
        return self
    }
}


extension String {
    /// Parses the ISO8601 string and returns a Date object, if possible.
    func parsedISODate() -> Date? {
        let isoFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        for format in isoFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) {
                return date
            }
        }

        return nil
    }
}
