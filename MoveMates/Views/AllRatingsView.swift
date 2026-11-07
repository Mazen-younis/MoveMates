//
//  AllRatingsView.swift
//  MoveMates
//
//  Created by Mazen Younis on 09/06/2025.
//

import SwiftUI

struct AllRatingsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var allRatings: [Rating] = []
    @State private var isLoading = true

    var body: some View {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Ratings")
                            .screenTitleStyle()

                        if allRatings.isEmpty {
                            Text("No ratings yet.")
                                .foregroundColor(.coolGray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                        } else {
                            ForEach(allRatings.sorted(by: { $0.date > $1.date })) { rating in
                                RatingCard(rating: rating)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .aquaBlue))
                }
            }
            .onAppear {
                loadRatings()
            }
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                sessionManager.navigationPath.removeLast(sessionManager.navigationPath.count)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Home")
                                }
                                .foregroundColor(.aquaBlue)
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }

    private func loadRatings() {
        guard let userId = sessionManager.currentUser?.id else { return }

        APIService.shared.fetchRatings(for: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    self.allRatings = data.received + data.given
                case .failure(let error):
                    print("Error loading ratings: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct RatingCard: View {
    let rating: Rating

    var isGivenByUser: Bool {
        rating.fromId == SessionManager.shared.currentUser?.id
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(.coolGray)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(isGivenByUser ? "You rated: \(rating.toName)" : "From: \(rating.fromName)")")
                    .font(.subheadline)
                    .foregroundColor(isGivenByUser ? .aquaBlue : .coolGray)

                Text("Date: \(rating.date.formattedDate())")
                    .font(.caption)
                    .foregroundColor(.coolGray)

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(rating.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }

                let trimmedFeedback = rating.feedback?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if !trimmedFeedback.isEmpty {
                    Text("\"\(trimmedFeedback)\"")
                        .italic()
                        .foregroundColor(.pureWhite)
                        .font(.footnote)
                        .padding(.top, 4)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.charcoalGray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isGivenByUser ? Color.aquaBlue : Color.clear, lineWidth: 1)
        )
    }

    private func formattedDate(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}

#Preview {
    let mockRatings: [Rating] = [
        Rating(id: 1, fromId: 1, fromName: "Ali", toId: 2, toName: "Mazen", rating: 5, feedback: "Great game!", date: "2025-06-05T12:00:00Z"),
        Rating(id: 2, fromId: 2, fromName: "Mazen", toId: 3, toName: "Sara", rating: 4, feedback: "Very cooperative!", date: "2025-06-04T18:30:00Z"),
        Rating(id: 3, fromId: 3, fromName: "John", toId: 2, toName: "Mazen", rating: 3, feedback: "Could improve timing.", date: "2025-06-03T14:15:00Z")
    ]

    return ZStack {
        Color.jetBlack.ignoresSafeArea()

        VStack(spacing: 16) {
            ForEach(mockRatings.sorted(by: { $0.date > $1.date })) { rating in
                RatingCard(rating: rating)
            }
        }
        .padding()
    }
    .environmentObject(SessionManager())
}
