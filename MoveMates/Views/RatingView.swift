//
//  RatingView.swift
//  MoveMates
//
//  Created by Mazen Younis on 09/05/2025.
//

import SwiftUI

struct RatingView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var overallRating = 0
    @State private var feedback = ""
    @State private var selectedMateId: Int? = nil
    @State private var showSuccessMessage = false
    @State private var showMatePicker = false
    @State private var mates: [PrivateChatSummary] = []

    var body: some View {
        ZStack {
            Color.jetBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Rate Your Mate")
                        .screenTitleStyle()
                        .multilineTextAlignment(.center)

                    Text("Select someone you recently talked to or met with.")
                        .font(.subheadline)
                        .foregroundColor(.coolGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Mates Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            showMatePicker = true
                        } label: {
                            HStack {
                                Text(selectedMate()?.name ?? "Select a Mate")
                                    .foregroundColor(.pureWhite)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.coolGray)
                            }
                            .padding()
                            .background(Color.charcoalGray)
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showMatePicker) {
                            pickerSheet(
                                title: "Choose a Mate",
                                items: mates.map { $0.name },
                                onSelect: { name in
                                    if let mate = mates.first(where: { $0.name == name }) {
                                        selectedMateId = mate.id
                                    }
                                    showMatePicker = false
                                },
                                onClose: {
                                    showMatePicker = false
                                }
                            )
                        }
                    }

                    // Star Rating
                    VStack(spacing: 8) {
                        Text("Your Rating")
                            .foregroundColor(.pureWhite)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= overallRating ? "star.fill" : "star")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        overallRating = star
                                    }
                            }
                        }
                    }

                    // Feedback
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Optional Feedback")
                            .foregroundColor(.pureWhite)
                            .font(.subheadline)

                        TextEditor(text: $feedback)
                            .frame(height: 100)
                            .padding(12)
                            .background(Color.charcoalGray)
                            .foregroundColor(.pureWhite)
                            .cornerRadius(10)
                            .scrollContentBackground(.hidden)
                    }

                    // Submit Button
                    Button(action: submitRating) {
                        Text("Submit Rating")
                            .moveMatesButtonStyle()
                    }
                    .disabled(selectedMateId == nil || overallRating == 0)

                    if showSuccessMessage {
                        Text("Thanks for your feedback!")
                            .font(.footnote)
                            .foregroundColor(.aquaBlue)
                            .padding(.top, 4)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .onAppear {
            loadMates()
        }
    }

    // Helpers
    func selectedMate() -> PrivateChatSummary? {
        return mates.first(where: { $0.id == selectedMateId })
    }

    func loadMates() {
        guard let userId = sessionManager.currentUser?.id else { return }

        APIService.shared.fetchChatMates(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedMates):
                    self.mates = fetchedMates
                case .failure(let error):
                    print("Error loading mates:", error.localizedDescription)
                }
            }
        }
    }

    func submitRating() {
        guard let mateId = selectedMateId, overallRating > 0,
              let raterId = sessionManager.currentUser?.id else { return }

        APIService.shared.submitRating(
            raterId: raterId,
            ratedId: mateId,
            rating: Float(overallRating),
            feedback: feedback
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                        overallRating = 0
                        feedback = ""
                        selectedMateId = nil
                    }
                case .failure(let error):
                    print("Error submitting rating:", error.localizedDescription)
                }
            }
        }
    }

    func pickerSheet(
        title: String,
        items: [String],
        onSelect: @escaping (String) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.pureWhite)
                Spacer()
                Button("Close", action: onClose)
                    .foregroundColor(.aquaBlue)
            }
            .padding()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.charcoalGray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                onSelect(item)
                            }
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top)
        .background(Color.jetBlack)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    RatingView()
        .environmentObject(SessionManager())
}
