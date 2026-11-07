import SwiftUI

struct RequestsView: View {
    @StateObject private var viewModel = RequestListViewModel()
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Join Requests")
                            .screenTitleStyle()

                        if viewModel.joinRequests.isEmpty {
                            Text("No requests yet.")
                                .foregroundColor(.coolGray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                        } else {
                            ForEach(viewModel.joinRequests.sorted(by: { $0.created_at > $1.created_at })) { request in
                                if let user = viewModel.allUsers.first(where: { $0.id == request.user_id }) {
                                    RequestCard(
                                        request: request,
                                        user: user,
                                        approveAction: {
                                            viewModel.approveRequest(requestId: request.id, gameId: request.game_id)
                                        },
                                        rejectAction: {
                                            viewModel.reject(requestId: request.id)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .onAppear {
                if let userId = sessionManager.currentUser?.id {
                    viewModel.loadGamesAndRequests(currentUserId: userId)
                    viewModel.loadAllUsers()
                }
            }
        }
    }
}

struct RequestCard: View {
    let request: JoinRequest
    let user: MoveMatesUser?
    let approveAction: () -> Void
    let rejectAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // User image
            if let user = user {
                NavigationLink(destination: UserProfileView(user: user)) {
                    AsyncImage(url: URL(string: user.profile_picture_url ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.coolGray)
                    }
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.aquaBlue, lineWidth: 1))
                }
            }

            // Request info
            VStack(alignment: .leading, spacing: 6) {
                Text("Game: \(request.game_sport ?? "Unknown") @ \(request.game_location ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.aquaBlue)

                if let user = user {
                    Text("Requested by: \(user.name) (@\(user.username))")
                        .font(.footnote)
                        .foregroundColor(.coolGray)
                } else {
                    Text("Requested by: Unknown User")
                        .font(.footnote)
                        .foregroundColor(.coolGray)
                }

                if request.status == "pending" {
                    HStack(spacing: 10) {
                        Button(action: approveAction) {
                            Text("Approve")
                                .font(.footnote.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                .background(Color.aquaBlue)
                                .foregroundColor(.jetBlack)
                                .cornerRadius(20)
                        }

                        Button(action: rejectAction) {
                            Text("Decline")
                                .font(.footnote.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                .background(Color.coolGray)
                                .foregroundColor(.pureWhite)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 4)
                } else {
                    Text("Status: \(request.status.capitalized)")
                        .font(.footnote)
                        .foregroundColor(.coolGray)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.charcoalGray)
        .cornerRadius(16)
    }
}

#Preview {
    let mockUser = MoveMatesUser(
        id: 2,
        name: "Ali",
        username: "ali99",
        email: "ali@example.com",
        skill_level: "Intermediate",
        sports: ["Tennis"],
        bio: "Let's play!",
        gender: "Male",
        preferred_sports_partner: "Any",
        favorite_times_to_play: ["Evenings"],
        phone_number: "000000000",
        notifications_enabled: true,
        profile_picture_url: nil,
        date_of_birth: "2000-01-01",
        location: "Berlin",
        created_at: "2025-01-01T12:00:00Z"
    )

    ZStack {
        Color.jetBlack.ignoresSafeArea()

        VStack(spacing: 16) {
            RequestCard(
                request: JoinRequest(
                    id: 1,
                    user_id: 2,
                    username: "Maz123",
                    game_id: 10,
                    status: "pending",
                    created_at: "2025-05-21T12:00:00Z",
                    game_sport: "Tennis",
                    game_location: "Mitte Park"
                ),
                user: mockUser,
                approveAction: {},
                rejectAction: {}
            )
            RequestCard(
                request: JoinRequest(
                    id: 2,
                    user_id: 3,
                    username: "Jad123",
                    game_id: 11,
                    status: "approved",
                    created_at: "2025-05-20T12:00:00Z",
                    game_sport: "Football",
                    game_location: "Prenzlauer Berg"
                ),
                user: mockUser,
                approveAction: {},
                rejectAction: {}
            )
        }
        .padding()
    }
}
