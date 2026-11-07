//
//  CountryHelper.swift
//  MoveMates
//
//  Created by Mazen Younis on 04/06/2025.
//

import Foundation

struct CountryHelper {
    static let validCountries: [String] = {
        let continentList: Set<String> = [
            "Africa", "Asia", "Europe", "Oceania", "North America",
            "South America", "Australasia", "Antarctica", "Americas"
        ]
        let isoCountries = Locale.Region.isoRegions.compactMap {
            Locale.current.localizedString(forRegionCode: $0.identifier)
        }
        let uniqueCountries = Set(isoCountries)
        let filteredCountries = uniqueCountries.subtracting(continentList)
        return filteredCountries.sorted()
    }()
}
