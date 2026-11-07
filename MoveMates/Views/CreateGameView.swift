import SwiftUI

struct CreateGameView: View {
    @StateObject private var viewModel = CreateGameViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var showSportPicker = false
    @State private var showLocationPicker = false
    @State private var showCustomDatePicker = false
    @State private var showCustomTimePicker = false

    @State private var sportSearchText = ""
    @State private var locationSearchText = ""

    @Binding var newlyCreatedGameId: Int?
    @Binding var selectedTab: HomePageView.Tab

    private let availableSports = [
        "Football", "Basketball", "Tennis", "Volleyball",
        "Running", "Yoga", "Gym", "Table Tennis",
        "Hiking", "Swimming", "Cycling"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jetBlack.ignoresSafeArea()
                ScrollView {
                    content
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Notice"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(isPresented: $showSportPicker) { sportPickerSheet }
            .sheet(isPresented: $showLocationPicker) { locationPickerSheet }
            .sheet(isPresented: $showCustomDatePicker) { datePickerSheet }
            .sheet(isPresented: $showCustomTimePicker) { timePickerSheet }
        }
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Create a Sports Event")
                .screenTitleStyle()

            sportPickerButton
            locationPickerButton
            currentLocationButton

            dateTimePicker

            neededPlayersPicker
            skillLevelPicker
            genderPreferencePicker

            createEventButton
        }
        .padding()
    }

    // MARK: - Picker Buttons
    private var sportPickerButton: some View {
        Button {
            showSportPicker = true
        } label: {
            HStack {
                Text(viewModel.sport.isEmpty ? "Select a Sport" : viewModel.sport)
                    .foregroundColor(.aquaBlue)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.coolGray)
            }
            .padding()
            .background(Color.charcoalGray)
            .cornerRadius(10)
        }
    }

    private var locationPickerButton: some View {
        Button {
            showLocationPicker = true
        } label: {
            HStack {
                Text(viewModel.location.isEmpty ? "Select a Location" : viewModel.location)
                    .foregroundColor(.aquaBlue)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.coolGray)
            }
            .padding()
            .background(Color.charcoalGray)
            .cornerRadius(10)
        }
    }

    private var currentLocationButton: some View {
        Group {
            if !locationManager.currentCountry.isEmpty {
                Button {
                    viewModel.location = locationManager.currentCountry
                } label: {
                    Label("Use Current Location: \(locationManager.currentCountry)", systemImage: "location.fill")
                        .foregroundColor(.aquaBlue)
                }
            } else {
                Text("Detecting current location...")
                    .foregroundColor(.coolGray)
                    .font(.footnote)
            }
        }
    }

    // MARK: - Date & Time Picker
    private var dateTimePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date & Time")
                .foregroundColor(.pureWhite)
            HStack(spacing: 12) {
                Button { showCustomDatePicker = true } label: {
                    Text(viewModel.formattedDate)
                        .foregroundColor(.aquaBlue)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.charcoalGray)
                        .cornerRadius(10)
                }

                Button { showCustomTimePicker = true } label: {
                    Text(viewModel.formattedTime)
                        .foregroundColor(.aquaBlue)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.charcoalGray)
                        .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Needed Players
    private var neededPlayersPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Needed Players")
                .foregroundColor(.pureWhite)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(1..<17) { number in
                        Text("\(number)")
                            .font(.headline)
                            .frame(width: 48, height: 48)
                            .background(
                                viewModel.neededPlayers == "\(number)" ? Color.aquaBlue : Color.charcoalGray
                            )
                            .foregroundColor(.pureWhite)
                            .clipShape(Circle())
                            .onTapGesture {
                                viewModel.neededPlayers = "\(number)"
                            }
                    }
                }
            }
        }
    }

    // MARK: - Skill Level
    private var skillLevelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Skill Level")
                .foregroundColor(.pureWhite)
            HStack(spacing: 12) {
                ForEach(viewModel.skillLevels, id: \.self) { level in
                    Text(level)
                        .font(.subheadline)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(viewModel.skillLevel == level ? Color.aquaBlue : Color.charcoalGray)
                        .foregroundColor(viewModel.skillLevel == level ? .jetBlack : .aquaBlue)
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.skillLevel = level
                        }
                }
            }
        }
    }


    // MARK: - Gender Preference
    private var genderPreferencePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender Preference")
                .foregroundColor(.pureWhite)
            HStack(spacing: 12) {
                ForEach(viewModel.genders, id: \.self) { gender in
                    Text(gender)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .frame(minWidth: 60)
                        .background(viewModel.genderPreference == gender ? Color.aquaBlue : Color.charcoalGray)
                        .foregroundColor(viewModel.genderPreference == gender ? .jetBlack : .aquaBlue)
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.genderPreference = gender
                        }
                }
            }
        }
    }

    // MARK: - Create Event Button
    private var createEventButton: some View {
        Button {
            if let user = sessionManager.currentUser {
                viewModel.createGame(currentUser: user) {
                    newlyCreatedGameId = viewModel.createdGameId
                    selectedTab = .joinEvent
                    dismiss()
                }
            } else {
                viewModel.alertMessage = "User not logged in"
                viewModel.showAlert = true
            }
        } label: {
            if viewModel.isSubmitting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.aquaBlue, .charcoalGray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            } else {
                Text("Create Event")
                    .moveMatesButtonStyle()
            }
        }
        .padding(.top, 10)
    }

    // MARK: - Picker Sheets
    private var sportPickerSheet: some View {
        pickerSheet(
            title: "Select a Sport",
            placeholder: "Search for a sport...",
            searchText: $sportSearchText,
            items: availableSports,
            onSelect: {
                viewModel.sport = $0
                showSportPicker = false
            },
            onClose: { showSportPicker = false }
        )
    }

    private var locationPickerSheet: some View {
        pickerSheet(
            title: "Select a Location",
            placeholder: "Search for a location...",
            searchText: $locationSearchText,
            items: CountryHelper.validCountries,
            onSelect: {
                viewModel.location = $0
                showLocationPicker = false
            },
            onClose: { showLocationPicker = false }
        )
    }

    private func pickerSheet(title: String, placeholder: String, searchText: Binding<String>, items: [String], onSelect: @escaping (String) -> Void, onClose: @escaping () -> Void) -> some View {
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

            ZStack(alignment: .leading) {
                if searchText.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.pureWhite.opacity(0.6))
                        .padding(.leading, 12)
                }

                TextField("", text: searchText)
                    .padding()
                    .background(Color.charcoalGray.opacity(0.4))
                    .cornerRadius(10)
                    .foregroundColor(.pureWhite)
                    .accentColor(.pureWhite)
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items.filter { searchText.wrappedValue.isEmpty || $0.localizedCaseInsensitiveContains(searchText.wrappedValue) }, id: \.self) { item in
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
    }

    private var datePickerSheet: some View {
        VStack {
            DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
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

    private var timePickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { showCustomTimePicker = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.aquaBlue)
                        .padding()
                }
            }

            DatePicker("", selection: $viewModel.date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.jetBlack)
                .colorScheme(.dark)

            Button("Done") { showCustomTimePicker = false }
                .padding()
                .foregroundColor(.aquaBlue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.jetBlack.ignoresSafeArea())
        .presentationDetents([.medium])
    }
}

#Preview {
    CreateGameView(
        newlyCreatedGameId: .constant(nil),
        selectedTab: .constant(.joinEvent)
    )
    .environmentObject(LocationManager())
    .environmentObject(SessionManager())
}
