import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.presentationMode) var presentationMode
    
    let user: MoveMatesUser
    @State private var averageRating: Double = 0.0
    @State private var ratersCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: user.profile_picture_url ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.coolGray)
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.top, 20)

                Text(user.name)
                    .font(.title2.bold())
                    .foregroundColor(.pureWhite)

                Text("@\(user.username)")
                    .foregroundColor(.coolGray)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(averageRating.rounded()) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    Text("(\(ratersCount) ratings)")
                        .foregroundColor(.coolGray)
                        .font(.caption)
                }

                VStack(alignment: .leading, spacing: 12) {
                    if let bio = user.bio, !bio.isEmpty {
                        profileSection(title: "About", content: bio)
                    }

                    if let skillLevel = user.skill_level, !skillLevel.isEmpty {
                        profileSection(title: "Skill Level", content: skillLevel)
                    }

                    if let gender = user.gender, !gender.isEmpty {
                        profileSection(title: "Gender", content: gender)
                    }

                    if let workoutTimes = user.favorite_times_to_play, !workoutTimes.isEmpty {
                        profileSection(title: "Preferred Times to Work Out", content: workoutTimes.joined(separator: "\n"))
                    }

                    // Sports Section
                    if let sports = user.sports, !sports.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sports")
                                .font(.headline)
                                .foregroundColor(.aquaBlue)

                            LazyVGrid(
                                columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3), // 3 per row max
                                alignment: .leading,
                                spacing: 8
                            ) {
                                ForEach(sports, id: \.self) { sport in
                                    Text(sport)
                                        .fixedSize(horizontal: true, vertical: false) // prevent word wrapping
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12) // smaller padding to help fit
                                        .background(Color.charcoalGray)
                                        .foregroundColor(.pureWhite)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    if let location = user.location, !location.isEmpty {
                        profileSection(title: "Location", content: location)
                    }

                    if let dob = user.date_of_birth, !dob.isEmpty {
                        profileSection(title: "Date of Birth", content: formatDateOfBirth(dob))
                    }

                    if let phone = user.phone_number, !phone.isEmpty {
                        profileSection(title: "Phone Number", content: phone)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .background(Color.jetBlack.ignoresSafeArea())
        .onAppear {
            fetchUserRating()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Fetch Rating
    private func fetchUserRating() {
        APIService.shared.fetchUserRating(userId: user.id ?? 0) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rating):
                    averageRating = rating.average
                    ratersCount = rating.count
                case .failure(let error):
                    print("Error fetching rating:", error.localizedDescription)
                }
            }
        }
    }

    private func profileSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.aquaBlue)
            Text(content)
                .foregroundColor(.pureWhite)
        }
    }

    private func formatDateOfBirth(_ dob: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dob) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MM-yyyy"
            return outputFormatter.string(from: date)
        }
        return dob // fallback
    }
}

#Preview {
    NavigationStack {
        let mockUser = MoveMatesUser(
            id: 1,
            name: "Alex Smith",
            username: "alexs",
            email: "alex@example.com",
            skill_level: "Advanced",
            sports: ["Football", "Running", "Yoga", "Gym", "Tennis"],
            bio: "Fitness enthusiast and team player.",
            gender: "Male",
            preferred_sports_partner: "Any",
            favorite_times_to_play: ["Weekdays: Morning", "Weekends: Evening"],
            phone_number: "123456789",
            notifications_enabled: true,
            profile_picture_url: nil,
            date_of_birth: "1995-06-10",
            location: "Berlin",
            created_at: "2025-01-01T00:00:00Z"
        )

        UserProfileView(user: mockUser)
            .environmentObject(SessionManager())
    }
}
