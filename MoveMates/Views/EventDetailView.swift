//
//  EventDetailView.swift
//  MoveMates
//
//  Created by Mazen Younis on 27/05/2025.
//

import SwiftUI

struct EventDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let game: Game
    let participants: [MoveMatesUser]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Event Details")
                    .screenTitleStyle()

                headerSection

                Divider().background(Color.coolGray)

                Text("Participants")
                    .font(.headline)
                    .foregroundColor(.aquaBlue)

                if participants.isEmpty {
                    Text("No participants yet.")
                        .foregroundColor(.coolGray)
                } else {
                    participantsList
                }

                Spacer()
                
                deleteButton
            }
            .padding()
        }
        .background(Color.jetBlack.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.aquaBlue)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(game.sport)
                .font(.title.bold())
                .foregroundColor(.pureWhite)

            Text("Location: \(game.location)")
                .foregroundColor(.coolGray)

            Text("Date: \(formattedDate(game.date))")
                .foregroundColor(.coolGray)
        }
    }

    private var participantsList: some View {
        VStack(spacing: 12) {
            ForEach(participants, id: \.id) { user in
                NavigationLink(destination: PrivateChatView(
                    senderId: SessionManager.shared.currentUser?.id ?? 0,
                    recipientId: user.id!,
                    recipientName: user.username,
                    viewModel: PrivateChatViewModel(
                        senderId: SessionManager.shared.currentUser?.id ?? 0,
                        recipientId: user.id!
                    ))
                ) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: user.profile_picture_url ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable()
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.coolGray)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .foregroundColor(.pureWhite)
                            Text("@\(user.username)")
                                .font(.caption)
                                .foregroundColor(.coolGray)
                        }

                        Spacer()

                        Image(systemName: "message")
                            .foregroundColor(.aquaBlue)
                    }
                    .padding()
                    .background(Color.charcoalGray.opacity(0.6))
                    .cornerRadius(12)
                }
            }
        }
    }

    private var deleteButton: some View {
        HStack {
            Spacer()
            Button(action: deleteGame) {
                Text("Delete Event")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.pureWhite)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.aquaBlue)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding(.vertical)
    }

    private func deleteGame() {
        APIService.shared.deleteGame(gameId: game.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Game deleted successfully.")
                    // Optionally show an alert to confirm deletion
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Error deleting game: \(error.localizedDescription)")
                    // Optionally show an alert to notify the user
                }
            }
        }
    }

    private func formattedDate(_ string: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: string) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "de_DE")
            displayFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
            return displayFormatter.string(from: date)
        }
        return string
    }
}

#Preview {
    let sampleGame = Game(
        id: 1,
        sport: "Basketball",
        location: "Mitte Court",
        date: "2025-06-01T18:00:00Z",
        needed_players: 5,
        skill_level: "Advanced",
        gender_preference: "Any",
        is_public: true,
        creator_id: 1,
        created_at: "2025-05-01T10:00:00Z"
    )

    let sampleUsers = [
        MoveMatesUser(
            id: 2,
            name: "John Doe",
            username: "johnny",
            email: "john@example.com",
            skill_level: "Advanced",
            sports: ["Basketball"],
            bio: "Let's play!",
            gender: "Male",
            preferred_sports_partner: "Any",
            favorite_times_to_play: ["Evenings"],
            phone_number: "1234567890",
            notifications_enabled: true,
            profile_picture_url: nil,
            date_of_birth: "1995-04-10",
            location: "Berlin",
            created_at: "2025-01-01T00:00:00Z"
        ),
        MoveMatesUser(
            id: 3,
            name: "Jane Smith",
            username: "janes",
            email: "jane@example.com",
            skill_level: "Intermediate",
            sports: ["Basketball"],
            bio: "Big fan of team sports.",
            gender: "Female",
            preferred_sports_partner: "Any",
            favorite_times_to_play: ["Weekends"],
            phone_number: "9876543210",
            notifications_enabled: true,
            profile_picture_url: nil,
            date_of_birth: "1998-12-01",
            location: "Berlin",
            created_at: "2025-01-01T00:00:00Z"
        )
    ]

    return EventDetailView(game: sampleGame, participants: sampleUsers)
        .background(Color.jetBlack)
}
