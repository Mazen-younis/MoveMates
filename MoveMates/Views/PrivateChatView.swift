//
//  PrivateChatView.swift
//  MoveMates
//
//  Created by Mazen Younis
//

import SwiftUI

struct PrivateChatView: View {
    let senderId: Int
    let recipientId: Int
    let recipientName: String

    @ObservedObject var viewModel: PrivateChatViewModel
    @State private var showProfile = false
    @State private var recipientUser: MoveMatesUser?
    @State private var timer: Timer?
    @State private var showTimestampFor: Set<Int> = []

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(Color.coolGray.opacity(0.4))
            messagesView
            Divider().background(Color.coolGray.opacity(0.4))
            messageInput
        }
        .background(Color.jetBlack.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchMessages()
            fetchRecipientProfile()
            timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                viewModel.fetchMessages()
            }
        }
        .onDisappear { timer?.invalidate() }
        .navigationDestination(isPresented: $showProfile) {
            if let user = recipientUser {
                UserProfileView(user: user)
                    .navigationTitle(user.username)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.aquaBlue)
                    .padding(.leading)
            }

            Button(action: { showProfile = true }) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: recipientUser?.profile_picture_url ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.coolGray)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipientUser?.username ?? recipientName)
                            .foregroundColor(.pureWhite)
                            .font(.headline)
                        if let location = recipientUser?.location {
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.coolGray)
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 10)
        .background(Color.charcoalGray)
    }

    // MARK: - Messages
    // MARK: - Messages
    private var messagesView: some View {
        ZStack {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .aquaBlue))
                        .scaleEffect(1.2)
                    Text("Loading chats…")
                        .foregroundColor(.white) // white color for better contrast
                        .font(.subheadline)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Spacer()
                }
            } else if viewModel.messages.isEmpty {
                VStack {
                    Spacer()
                    Text("No messages yet.")
                        .foregroundColor(.coolGray)
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(viewModel.messages.indices, id: \.self) { index in
                                let message = viewModel.messages[index]
                                let isSameSenderAsPrevious = index > 0 && viewModel.messages[index - 1].sender_id == message.sender_id
                                messageBubble(message, isSameSenderAsPrevious: isSameSenderAsPrevious)
                                    .id(message.id)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
    }

    private func messageBubble(_ message: Message, isSameSenderAsPrevious: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.sender_id == viewModel.senderId {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(message.content)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.aquaBlue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .onTapGesture { toggleTimestamp(for: message) }

                        if message.read {
                            ZStack {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .offset(x: 3, y: 0)
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                            }
                            .foregroundColor(.aquaBlue)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.caption2)
                                .foregroundColor(.aquaBlue)
                        }
                    }
                    if showTimestampFor.contains(message.id) {
                        Text(message.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.coolGray)
                            .transition(.opacity)
                    }
                }
                .padding(.trailing)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(message.content)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.charcoalGray)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .onTapGesture { toggleTimestamp(for: message) }

                    if showTimestampFor.contains(message.id) {
                        Text(message.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.coolGray)
                            .transition(.opacity)
                    }
                }
                .padding(.leading)
                Spacer()
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, isSameSenderAsPrevious ? 1 : 4)
    }

    // MARK: - Message Input
    private var messageInput: some View {
        HStack(spacing: 8) {
            TextField("Type a message...", text: $viewModel.newMessageText)
                .padding(12)
                .background(Color.charcoalGray)
                .foregroundColor(.pureWhite)
                .cornerRadius(20)

            Button(action: { viewModel.sendMessage() }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .background(viewModel.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.coolGray : Color.aquaBlue)
                    .clipShape(Circle())
            }
            .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(Color.jetBlack)
    }

    private func toggleTimestamp(for message: Message) {
        if showTimestampFor.contains(message.id) {
            showTimestampFor.remove(message.id)
        } else {
            showTimestampFor.insert(message.id)
        }
    }

    private func fetchRecipientProfile() {
        APIService.shared.getUserById(id: recipientId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    recipientUser = user
                case .failure(let error):
                    print("Failed to fetch recipient profile: \(error)")
                }
            }
        }
    }
}

#Preview {
    PrivateChatView(
        senderId: 1,
        recipientId: 2,
        recipientName: "Alex",
        viewModel: PrivateChatViewModel(senderId: 1, recipientId: 2)
    )
}
