import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [MoveMatesUser] = []

    func loadUsers() {
        APIService.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error):
                    print("Error fetching users:", error)
                }
            }
        }
    }
}

