import SwiftUI

struct MyEventsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = MyEventsViewModel()

    var body: some View {
        ZStack {
            Color.jetBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Text("My Events")
                        .screenTitleStyle()
                    Spacer()
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView("Loading your events…")
                        .tint(.aquaBlue)
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.sortedMyGames.isEmpty {
                    Text("You haven't created any events yet.")
                        .foregroundColor(.coolGray)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.sortedMyGames) { event in
                                NavigationLink(destination: EventDetailView(game: event, participants: viewModel.participants[event.id] ?? [])) {
                                    EventCardView(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top)
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
        .onAppear {
            if let userId = sessionManager.currentUser?.id {
                viewModel.fetchMyGames(userId: userId)
            }
        }
    }
}

// Event Card
struct EventCardView: View {
    let event: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.sport)
                    .font(.headline)
                    .foregroundColor(.aquaBlue)

                Spacer()

                Text(isUpcoming(event.date) ? "Upcoming" : "Completed")
                    .font(.caption)
                    .foregroundColor(.coolGray)
            }

            Text(event.location)
                .font(.subheadline)
                .foregroundColor(.pureWhite)

            Text(event.date.formattedDate())
                .font(.caption)
                .foregroundColor(.coolGray)
        }
        .padding()
        .background(Color.charcoalGray)
        .cornerRadius(14)
    }

    private func isUpcoming(_ iso: String) -> Bool {
        if let date = iso.parsedISODate() {
            return date > Date()
        }
        return false
    }
}

#Preview {
    NavigationStack {
        MyEventsView().environmentObject(SessionManager())
    }
}
