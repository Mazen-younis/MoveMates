import SwiftUI

struct HomePageView: View {
    enum Tab {
        case joinEvent, createEvent, messages, rateMates, requests
    }

    enum NavigationTarget: Hashable {
        case editProfile
        case myEvents
        case termsPrivacy
        case helpSupport
        case createEvent
        case userProfile(user: MoveMatesUser)
        case ratings
    }

    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab: Tab = .joinEvent
    @State private var isMenuOpen = false
    @State private var newlyCreatedGameId: Int? = nil

    var body: some View {
        NavigationStack(path: $sessionManager.navigationPath) {
            ZStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("Welcome, \(sessionManager.currentUser?.name ?? "Player")!")
                                .screenTitleStyle()
                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Spacer()

                        switch selectedTab {
                        case .joinEvent:
                            GameListView(highlightedGameId: newlyCreatedGameId, showBackButton: false)
                        case .createEvent:
                            CreateGameView(newlyCreatedGameId: $newlyCreatedGameId, selectedTab: $selectedTab)
                        case .messages:
                            ChatListView()
                        case .rateMates:
                            RatingView()
                        case .requests:
                            RequestsView()
                        }

                        Spacer()

                        HStack(spacing: 0) {
                            tabButton(title: "Join Event", icon: "figure.walk", tab: .joinEvent)
                            tabButton(title: "Create Event", icon: "plus.circle", tab: .createEvent)
                            tabButton(title: "Messages", icon: "bubble.left.and.bubble.right", tab: .messages)
                            tabButton(title: "Rate Mates", icon: "star", tab: .rateMates)
                            tabButton(title: "Requests", icon: "person.badge.plus", tab: .requests)
                        }
                        .background(Color.charcoalGray)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .background(Color.jetBlack)
                    .offset(x: isMenuOpen ? UIScreen.main.bounds.width * 0.7 : 0)
                    .animation(.easeInOut(duration: 0.25), value: isMenuOpen)

                    if isMenuOpen {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation { isMenuOpen = false }
                            }
                    }

                    Button(action: {
                        withAnimation { isMenuOpen.toggle() }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .padding()
                            .foregroundColor(.pureWhite)
                    }
                }
                .zIndex(1)

                SideMenuView(isMenuOpen: $isMenuOpen, navigationPath: $sessionManager.navigationPath)
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                    .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.width * 0.7)
                    .zIndex(2)
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .editProfile:
                    AnyView(EditProfileView())
                case .myEvents:
                    AnyView(MyEventsView())
                case .termsPrivacy:
                    AnyView(TermsPrivacyView())
                case .helpSupport:
                    AnyView(HelpSupportView())
                case .createEvent:
                    AnyView(CreateGameView(newlyCreatedGameId: $newlyCreatedGameId, selectedTab: $selectedTab))
                case .userProfile(let user):
                    AnyView(UserProfileView(user: user))
                case .ratings:
                    AnyView(AllRatingsView()) 
                }
            }
        }
    }

    private func tabButton(title: String, icon: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.headline)
                Text(title).font(.caption)
            }
            .foregroundColor(selectedTab == tab ? .aquaBlue : .coolGray)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(SessionManager())
        .environmentObject(LocationManager())
}
