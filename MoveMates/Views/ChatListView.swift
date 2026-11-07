import SwiftUI

struct ChatListView: View {
    @StateObject private var privateChatVM = PrivateChatListViewModel()
    @EnvironmentObject var sessionManager: SessionManager

    @State private var searchText = ""
    @State private var showSearch = false
    @State private var selectedPrivateChat: PrivateChatSummary?
    @State private var showPrivateChatView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Chats")
                        .screenTitleStyle()

                    if showSearch {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.coolGray)
                            TextField("Search chats", text: $searchText)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.charcoalGray)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .transition(.move(edge: .top))
                    }

                    if privateChatVM.isLoading {
                        ProgressView("Loading chats…")
                            .tint(.aquaBlue)
                            .padding()
                    } else if let error = privateChatVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        chatListContent
                    }
                }
                .padding(.top)
            }
            .onAppear {
                if let userId = sessionManager.currentUser?.id {
                    privateChatVM.fetchPrivateChats(for: userId)
                }
            }
            .navigationDestination(isPresented: $showPrivateChatView) {
                if let privateChat = selectedPrivateChat {
                    PrivateChatView(
                        senderId: sessionManager.currentUser?.id ?? 0,
                        recipientId: privateChat.id,
                        recipientName: privateChat.name,
                        viewModel: PrivateChatViewModel(
                            senderId: sessionManager.currentUser?.id ?? 0,
                            recipientId: privateChat.id
                        )
                    )
                }
            }
        }
    }

    // MARK: - Chat List Content
    private var chatListContent: some View {
        List {
            let sortedChats = privateChatVM.privateChats
                .sorted { $0.timestamp > $1.timestamp }
                .filter {
                    searchText.isEmpty ||
                    $0.name.localizedCaseInsensitiveContains(searchText) ||
                    $0.lastMessage.localizedCaseInsensitiveContains(searchText)
                }

            ForEach(sortedChats) { chat in
                VStack(spacing: 0) {
                    chatCard(chat)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                privateChatVM.deleteChat(chatId: chat.id)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.aquaBlue)
                            }
                            .tint(Color.clear) 
                        }
                        .onTapGesture {
                            selectedPrivateChat = chat
                            showPrivateChatView = true
                        }

                    Divider()
                        .background(Color.aquaBlue.opacity(0.4))
                        .padding(.leading, 70) // align with text
                }
                .listRowInsets(EdgeInsets()) // remove default padding
                .listRowBackground(Color.jetBlack)
            }
        }
        .listStyle(.plain)
        .background(Color.jetBlack)
    }

    // MARK: - Chat Card UI
    private func chatCard(_ chat: PrivateChatSummary) -> some View {
        HStack(spacing: 12) {
            if let imageUrl = chat.profile_picture_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 48, height: 48)
                    case .success(let image):
                        image.resizable()
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.coolGray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.coolGray)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.pureWhite)
                    .lineLimit(1)

                Text(chat.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.coolGray)
                    .lineLimit(1)
            }

            Spacer()

            Text(chat.timestamp)
                .font(.caption2)
                .foregroundColor(.coolGray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color.jetBlack)
    }
}

#Preview {
    let mockSession = SessionManager()
    mockSession.currentUser = MoveMatesUser(
        id: 1,
        name: "You",
        username: "you123",
        email: "you@example.com",
        skill_level: "Intermediate",
        sports: ["Football"],
        bio: "Ready to play!",
        gender: "Male",
        preferred_sports_partner: "Any",
        favorite_times_to_play: ["Evening"],
        phone_number: "000000000",
        notifications_enabled: true,
        profile_picture_url: nil,
        date_of_birth: "2000-01-01",
        location: "Berlin",
        created_at: "2025-01-01"
    )

    return ChatListView()
        .environmentObject(mockSession)
}
