//
//  SetupProfileView.swift
//  MoveMates
//
//  Created by Mazen Younis on 09/05/2025.
//


import SwiftUI

struct SetupProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var bio = ""
    @State private var gender = "Prefer not to say"
    @State private var phoneNumber = ""
    @State private var notificationsEnabled = true
    @State private var profileImage: UIImage? = nil
    @State private var workoutSelections: [(day: String, time: String)] = [("Weekdays", "Morning")]
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var location = ""
    @State private var shouldNavigateToHome = false

    @State private var showGenderPicker = false
    @State private var showCustomDatePicker = false
    @State private var showDayPicker = false
    @State private var showTimePicker = false
    @State private var selectedWorkoutIndex: Int? = nil
    @State private var selectedSports: [String] = []
    @State private var profilePictureUrl: String? = nil
    @State private var skillLevel: String = ""
    

    let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    let timeOptions = ["Morning", "Afternoon", "Evening"]
    let dayOptions = ["Weekdays", "Weekends"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Complete Your Profile")
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

                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .foregroundColor(.pureWhite)

                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("Tell your mates about yourself...")
                                        .foregroundColor(.pureWhite.opacity(0.6))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                }

                                TextEditor(text: $bio)
                                    .padding(14)
                                    .frame(minHeight: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.charcoalGray)
                                    )
                                    .foregroundColor(.pureWhite)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.charcoalGray.opacity(0.6), lineWidth: 1)
                                    )
                                    .scrollContentBackground(.hidden)
                            }
                        }

                        // Gender Picker
                        Text("Gender")
                            .foregroundColor(.pureWhite)

                        Button {
                            showGenderPicker = true
                        } label: {
                            pickerBox(title: gender)
                        }
                        .sheet(isPresented: $showGenderPicker) {
                            pickerSheet(
                                title: "Select Gender",
                                placeholder: "",
                                searchText: .constant(""),
                                items: genderOptions,
                                onSelect: { selected in
                                    gender = selected
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

                        // Location
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your City or Area")
                                .foregroundColor(.pureWhite)
                            TextField("e.g. Berlin, Mitte", text: $location)
                                .padding()
                                .background(Color.charcoalGray)
                                .cornerRadius(10)
                                .foregroundColor(.pureWhite)
                        }

                        // Workout Times
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

                        // Phone Number
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number (Optional)")
                                .foregroundColor(.pureWhite)
                            TextField("Enter phone number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color.charcoalGray)
                                .cornerRadius(10)
                                .foregroundColor(.pureWhite)
                        }

                        // Notifications Toggle
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .aquaBlue))
                            .foregroundColor(.pureWhite)

                        Button(action: submitProfile) {
                            Text("Save and Continue")
                                .moveMatesButtonStyle()
                        }
                    }
                    .padding()
                }

                // Sheets
                .sheet(isPresented: $showDayPicker) {
                    pickerSheet(
                        title: "Select Day",
                        placeholder: "",
                        searchText: .constant(""),
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
                        placeholder: "",
                        searchText: .constant(""),
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

                .sheet(isPresented: $showCustomDatePicker) {
                    VStack {
                        DatePicker("Select Date", selection: $dateOfBirth, displayedComponents: .date)
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

                // Navigation
                .navigationDestination(isPresented: $shouldNavigateToHome) {
                    HomePageView()
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func submitProfile() {
        guard let userId = sessionManager.currentUser?.id else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dob = formatter.string(from: dateOfBirth)

        APIService.shared.updateProfile(
            userId: userId,
            bio: bio,
            gender: gender,
            favoriteTimes: workoutSelections.map { "\($0.day): \($0.time)" },
            phoneNumber: phoneNumber,
            notificationsEnabled: notificationsEnabled,
            dateOfBirth: dob,
            sports: selectedSports,
            location: location,
            profilePictureUrl: profilePictureUrl,
            skillLevel: skillLevel
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    sessionManager.currentUser = updatedUser
                    sessionManager.hasCompletedProfile = true
                    shouldNavigateToHome = true
                case .failure(let error):
                    print("Profile update error:", error)
                }
            }
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
        placeholder: String,
        searchText: Binding<String>,
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
    SetupProfileView().environmentObject(SessionManager())
}
