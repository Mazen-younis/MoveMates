import SwiftUI

struct GameListView: View {
    @StateObject private var viewModel = GameListViewModel()
    var highlightedGameId: Int?
    var showBackButton: Bool = false

    @Environment(\.dismiss) private var dismiss

    // Filtered games that are still active (not past and have needed players)
    var availableGames: [Game] {
        viewModel.games.filter { game in
            // Parse date using your shared extension
            if let gameDate = game.date.parsedISODate() {
                let isFuture = gameDate > Date()
                let hasPlayers = game.needed_players > 0
                return isFuture && hasPlayers
            }
            return false
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    if showBackButton {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Home")
                            }
                            .foregroundColor(.aquaBlue)
                        }
                        .padding(.horizontal)
                    }

                    Text("Join a Sports Event")
                        .screenTitleStyle()

                    if availableGames.isEmpty {
                        Text("No sports events available right now.")
                            .foregroundColor(.coolGray)
                            .padding(.horizontal)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(availableGames) { game in
                                    NavigationLink(destination: GameDetailView(game: game)) {
                                        gameCard(for: game)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.loadGames()
            }
        }
    }

    @ViewBuilder
    private func gameCard(for game: Game) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(game.sport)
                    .font(.headline)
                    .foregroundColor(.aquaBlue)

                Spacer()

                Image(systemName: viewModel.expandedGameId == game.id ? "chevron.up" : "chevron.down")
                    .foregroundColor(.coolGray)
                    .onTapGesture {
                        withAnimation {
                            viewModel.expandedGameId = (viewModel.expandedGameId == game.id) ? nil : game.id
                        }
                    }
            }

            if viewModel.expandedGameId == game.id {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(game.location)
                    }

                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("Players needed: \(game.needed_players)")
                    }

                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Skill: \(game.skill_level)")
                    }

                    HStack {
                        Image(systemName: "figure.stand.line.dotted.figure.stand")
                        Text("Gender: \(game.gender_preference)")
                    }

                    HStack {
                        Image(systemName: "calendar")
                        Text(game.date.formattedDate())
                    }
                }
                .font(.subheadline)
                .foregroundColor(.pureWhite)
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.charcoalGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(highlightedGameId == game.id ? Color.aquaBlue : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    GameListView(highlightedGameId: 1, showBackButton: true)
        .environmentObject(SessionManager.shared)
}
