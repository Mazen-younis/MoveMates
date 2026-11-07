import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var name: String = ""
    @State private var city: String = ""
    @State private var skillLevel: String = ""
    @State private var bioText: String = ""
    @State private var selectedGender: String = ""
    @State private var partnerPreference: String = ""
    @State private var message: String? = nil
    @State private var selectedSports: [String] = []
    @State private var profileImage: UIImage? = nil
    @State private var profilePictureUrl: String? = nil

    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var showCustomDatePicker = false

    // Workout times
    @State private var workoutSelections: [(day: String, time: String)] = []
    @State private var selectedWorkoutIndex: Int? = nil
    @State private var showDayPicker = false
    @State private var showTimePicker = false

    @State private var showGenderPicker = false
    @State private var showSkillLevelPicker = false

    private let availableSports = [
        "Football", "Basketball", "Tennis", "Volleyball",
        "Running", "Yoga", "Gym", "Table Tennis",
        "Hiking", "Swimming", "Cycling"
    ]
    private let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    private let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    private let timeOptions = ["Morning", "Afternoon", "Evening"]
    private let dayOptions = ["Weekdays", "Weekends"]

    var body: some View {
        ZStack {
            Color.jetBlack.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("Edit Your Profile")
                        .screenTitleStyle()

                    HStack {
                        Spacer()
                        ProfileImagePicker(image: $profileImage)
                        Spacer()
                    }

                    if let username = sessionManager.currentUser?.username {
                        Text("@\(username)")
                            .font(.headline)
                            .foregroundColor(.coolGray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    profileTextField(label: "Name", text: $name)
                    profileTextField(label: "City", text: $city)

                    Text("Skill Level")
                        .foregroundColor(.pureWhite)
                    Button {
                        showSkillLevelPicker = true
                    } label: {
                        pickerBox(title: skillLevel.isEmpty ? "Select Skill Level" : skillLevel)
                    }
                    .sheet(isPresented: $showSkillLevelPicker) {
                        pickerSheet(
                            title: "Select Skill Level",
                            items: skillLevels,
                            onSelect: {
                                skillLevel = $0
                                showSkillLevelPicker = false
                            },
                            onClose: { showSkillLevelPicker = false }
                        )
                    }

                    Text("Gender")
                        .foregroundColor(.pureWhite)
                    Button {
                        showGenderPicker = true
                    } label: {
                        pickerBox(title: selectedGender.isEmpty ? "Select Gender" : selectedGender)
                    }
                    .sheet(isPresented: $showGenderPicker) {
                        pickerSheet(
                            title: "Select Gender",
                            items: genderOptions,
                            onSelect: {
                                selectedGender = $0
                                showGenderPicker = false
                            },
                            onClose: { showGenderPicker = false }
                        )
                    }

                    // Date of Birth
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date of Birth")
                            .foregroundColor(.pureWhite)

                        Button {
                            showCustomDatePicker = true
                        } label: {
                            Text(formattedDate(dateOfBirth))
                                .foregroundColor(.aquaBlue)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color.charcoalGray)
                                .cornerRadius(10)
                        }
                    }

                    // Workout Times Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preferred Times to Work Out")
                            .foregroundColor(.pureWhite)

                        ForEach(workoutSelections.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                Button {
                                    selectedWorkoutIndex = index
                                    showDayPicker = true
                                } label: {
                                    pickerBox(title: workoutSelections[index].day)
                                }

                                Button {
                                    selectedWorkoutIndex = index
                                    showTimePicker = true
                                } label: {
                                    pickerBox(title: workoutSelections[index].time)
                                }

                                if workoutSelections.count > 1 {
                                    Button(action: {
                                        workoutSelections.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.aquaBlue)
                                    }
                                }
                            }
                        }

                        Button {
                            workoutSelections.append(("Weekdays", "Morning"))
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add another time")
                            }
                            .foregroundColor(.aquaBlue)
                        }
                    }

                    // Sports selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Sports")
                            .foregroundColor(.pureWhite)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(availableSports, id: \.self) { sport in
                                Text(sport)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSports.contains(sport) ? Color.aquaBlue : Color.charcoalGray)
                                    .foregroundColor(selectedSports.contains(sport) ? .jetBlack : .aquaBlue)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if selectedSports.contains(sport) {
                                            selectedSports.removeAll { $0 == sport }
                                        } else {
                                            selectedSports.append(sport)
                                        }
                                    }
                            }
                        }
                    }

                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .foregroundColor(.pureWhite)
                        ZStack(alignment: .topLeading) {
                            if bioText.isEmpty {
                                Text("Tell others a bit about yourself…")
                                    .foregroundColor(.pureWhite.opacity(0.6))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                            }
                            TextEditor(text: $bioText)
                                .padding(14)
                                .frame(minHeight: 100)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.charcoalGray))
                                .foregroundColor(.pureWhite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.charcoalGray.opacity(0.6), lineWidth: 1)
                                )
                                .scrollContentBackground(.hidden)
                        }
                    }

                    if let msg = message {
                        Text(msg)
                            .foregroundColor(.aquaBlue)
                            .font(.footnote)
                    }

                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .moveMatesButtonStyle()
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    sessionManager.navigationPath = NavigationPath()
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
        .onAppear(perform: loadUserData)

        // Date Picker Sheet
        .sheet(isPresented: $showCustomDatePicker) {
            VStack {
                DatePicker("Select Date", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.jetBlack)
                    .colorScheme(.dark)

                Button("Done") { showCustomDatePicker = false }
                    .padding()
                    .foregroundColor(.aquaBlue)
            }
            .presentationDetents([.medium])
            .background(Color.jetBlack)
        }

        // Workout Time Pickers
        .sheet(isPresented: $showDayPicker) {
            pickerSheet(
                title: "Select Day",
                items: dayOptions,
                onSelect: { selected in
                    if let index = selectedWorkoutIndex {
                        workoutSelections[index].day = selected
                    }
                    showDayPicker = false
                },
                onClose: { showDayPicker = false }
            )
        }
        .sheet(isPresented: $showTimePicker) {
            pickerSheet(
                title: "Select Time",
                items: timeOptions,
                onSelect: { selected in
                    if let index = selectedWorkoutIndex {
                        workoutSelections[index].time = selected
                    }
                    showTimePicker = false
                },
                onClose: { showTimePicker = false }
            )
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    func profileTextField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .foregroundColor(.pureWhite)
            TextField(label, text: text)
                .padding()
                .background(Color.charcoalGray)
                .cornerRadius(10)
                .foregroundColor(.pureWhite)
        }
    }

    private func pickerBox(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.pureWhite)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.coolGray)
        }
        .padding()
        .background(Color.charcoalGray.opacity(0.3))
        .cornerRadius(10)
    }

    private func pickerSheet(
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Logic
    func loadUserData() {
        guard let user = sessionManager.currentUser else { return }
        name = user.name
        city = user.location ?? ""
        skillLevel = user.skill_level ?? ""
        bioText = user.bio ?? ""
        selectedGender = user.gender ?? ""
        partnerPreference = user.preferred_sports_partner ?? ""
        selectedSports = user.sports ?? []

        if let favTimes = user.favorite_times_to_play {
            workoutSelections = favTimes.compactMap {
                let parts = $0.split(separator: ":")
                if parts.count == 2 {
                    return (day: String(parts[0]), time: String(parts[1]))
                }
                return nil
            }
        }
        if workoutSelections.isEmpty {
            workoutSelections.append(("Weekdays", "Morning"))
        }

        if let dobString = user.date_of_birth {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let dobDate = formatter.date(from: dobString) {
                dateOfBirth = dobDate
            }
        }
    }

    
    func saveProfile() {
        guard let user = sessionManager.currentUser else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dob = formatter.string(from: dateOfBirth)

        if let selectedImage = profileImage {
            // Upload the profile picture first
            APIService.shared.uploadProfilePicture(image: selectedImage) { result in
                switch result {
                case .success(let imageUrl):
                    // Image uploaded successfully — now update the profile with the new picture URL
                    updateProfile(userId: user.id!, profilePictureUrl: imageUrl, dateOfBirth: dob)

                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Upload error:", error.localizedDescription)
                        message = "Failed to upload profile picture."
                    }
                }
            }
        } else {
            updateProfile(userId: user.id!, profilePictureUrl: profilePictureUrl, dateOfBirth: dob)
        }
    }

    private func updateProfile(userId: Int, profilePictureUrl: String?, dateOfBirth: String) {
        APIService.shared.updateProfile(
            userId: userId,
            bio: bioText,
            gender: selectedGender,
            favoriteTimes: workoutSelections.map { "\($0.day): \($0.time)" },
            phoneNumber: sessionManager.currentUser?.phone_number,
            notificationsEnabled: sessionManager.currentUser?.notifications_enabled ?? false,
            dateOfBirth: dateOfBirth,
            sports: selectedSports,
            location: city.isEmpty ? nil : city,
            profilePictureUrl: profilePictureUrl,
            skillLevel: skillLevel,
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    sessionManager.currentUser = updatedUser
                    message = "Profile updated successfully."

                case .failure(let error):
                    print("Profile update failed:", error)
                    message = "Failed to update profile."
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        let mockSession = SessionManager()
        mockSession.currentUser = MoveMatesUser(
            id: 0,
            name: "Mark",
            username: "marky",
            email: "test@test.com",
            skill_level: "Intermediate",
            sports: ["Football", "Tennis"],
            bio: "Love sports!",
            gender: "Male",
            preferred_sports_partner: "Any",
            favorite_times_to_play: ["Weekdays: Morning", "Weekends: Evening"],
            phone_number: "1234567890",
            notifications_enabled: true,
            profile_picture_url: nil,
            date_of_birth: "1999-05-20",
            location: "Berlin",
            created_at: "2025-05-09T00:00:00Z"
        )
        return EditProfileView().environmentObject(mockSession)
    }
}
