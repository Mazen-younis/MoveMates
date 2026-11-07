import SwiftUI

struct GameDetailView: View {
    let game: Game

    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var joinRequests: [JoinRequest] = []
    @State private var navigateToPrivateChat = false
    @State private var allUsers: [MoveMatesUser] = []

    @StateObject private var joinGameVM = JoinGameViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(game.sport)
                    .screenTitleStyle()

                gameDetailRow("Location", game.location)
                gameDetailRow("Skill Level", game.skill_level)
                gameDetailRow("Needed Players", "\(game.needed_players)")
                gameDetailRow("Gender Preference", game.gender_preference)
                gameDetailRow("Date", formatDate(game.date))
                gameDetailRow("Public", game.is_public ? "Yes" : "No")

                Divider().background(Color.coolGray)

                if sessionManager.currentUser?.id != game.creator_id {
                    Button(action: requestToJoin) {
                        if joinGameVM.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Request to Join Event")
                        }
                    }
                    .moveMatesButtonStyle()
                    .padding(.top, 10)
                }

                if sessionManager.currentUser?.id == game.creator_id {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Join Requests")
                            .font(.headline)
                            .foregroundColor(.pureWhite)

                        if joinRequests.isEmpty {
                            Text("No pending requests yet.")
                                .foregroundColor(.coolGray)
                        } else {
                            ForEach(joinRequests) { request in
                                VStack(alignment: .leading, spacing: 6) {
                                    let username = getUsername(for: request.user_id)
                                    Text("Username: \(username)")
                                        .font(.subheadline)
                                        .foregroundColor(.pureWhite)

                                    Text("Status: \(request.status.capitalized)")
                                        .font(.subheadline)
                                        .foregroundColor(request.status == "pending" ? .orange : .coolGray)

                                    if request.status == "pending" {
                                        Button(action: {
                                            approveRequest(request.id)
                                        }) {
                                            Text("Approve")
                                                .moveMatesButtonStyle()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.charcoalGray)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .background(Color.jetBlack.ignoresSafeArea())
        .onAppear {
            loadJoinRequestsIfCreator()
            loadAllUsers()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $joinGameVM.showAlert) {
            Alert(title: Text("Notice"), message: Text(joinGameVM.alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationDestination(isPresented: $navigateToPrivateChat) {
            if let userId = sessionManager.currentUser?.id {
                PrivateChatView(
                    senderId: userId,
                    recipientId: game.creator_id,
                    recipientName: "Chat",
                    viewModel: PrivateChatViewModel(senderId: userId, recipientId: game.creator_id)
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
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

    func gameDetailRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.coolGray)
            Spacer()
            Text(value ?? "-")
                .font(.subheadline)
                .foregroundColor(.pureWhite)
        }
    }

    func formatDate(_ isoDate: String) -> String {
        return isoDate.formattedDate()
    }

    // MARK: - Lookup for username
    func getUsername(for userId: Int) -> String {
        return allUsers.first(where: { $0.id == userId })?.username ?? "Unknown"
    }

    // MARK: - Actions
    func requestToJoin() {
        guard let userId = sessionManager.currentUser?.id else {
            alertMessage = "You must be logged in to request to join."
            showAlert = true
            return
        }

        joinGameVM.checkAndRequestJoin(userId: userId, gameId: game.id)
    }

    func approveRequest(_ requestId: Int) {
        APIService.shared.approveJoinRequest(requestId: requestId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    alertMessage = "Request approved!"
                    loadJoinRequestsIfCreator()
                case .failure(let error):
                    alertMessage = "Approval failed: \(error.localizedDescription)"
                }
                showAlert = true
            }
        }
    }

    func loadJoinRequestsIfCreator() {
        if sessionManager.currentUser?.id == game.creator_id {
            APIService.shared.fetchJoinRequestsForUser(userId: sessionManager.currentUser?.id ?? 0) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let requests):
                        self.joinRequests = requests
                    case .failure(let error):
                        print("Error fetching join requests:", error.localizedDescription)
                    }
                }
            }
        }
    }

    func loadAllUsers() {
        APIService.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.allUsers = users
                case .failure(let error):
                    print("Failed to load users: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    GameDetailView(game: Game(
        id: 1,
        sport: "Football",
        location: "Berlin",
        date: "2025-05-22T14:09:00.000000",
        needed_players: 5,
        skill_level: "Intermediate",
        gender_preference: "Any",
        is_public: true,
        creator_id: 1,
        created_at: "2025-05-16T10:00:00Z"
    ))
    .environmentObject(SessionManager())
}
