//
//  CitySelectorView.swift
//  MoveMates
//
//  Created by Mazen Younis on 09/05/2025.
//

import SwiftUI

struct CitySelectorView: View {
    @Binding var selectedCity: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""

    // List of real countries only (removing continents)
    let countries: [String] = CountryHelper.validCountries

    var filteredCountries: [String] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ZStack {
            Color.jetBlack.ignoresSafeArea()

            VStack {
                Text("Select a Location")
                    .font(.title2.bold())
                    .foregroundColor(.pureWhite)
                    .padding(.top)

                TextField("Search for a location...", text: $searchText)
                    .padding(12)
                    .background(Color.charcoalGray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredCountries, id: \.self) { country in
                            Button {
                                selectedCity = country
                                dismiss()
                            } label: {
                                HStack {
                                    Text(country)
                                        .foregroundColor(.pureWhite)
                                    Spacer()
                                    if selectedCity == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.aquaBlue)
                                    }
                                }
                                .padding()
                                .background(Color.charcoalGray)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.aquaBlue)
            }
        }
    }
}

#Preview {
    CitySelectorView(selectedCity: .constant("Germany"))
}
