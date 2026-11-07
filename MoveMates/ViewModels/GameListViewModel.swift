import Foundation

class GameListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var expandedGameId: Int? = nil
    
    init() {}

    func loadGames() {
        APIService.shared.fetchGames { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.games = games.sorted(by: { $0.created_at > $1.created_at })
                case .failure(let error):
                    print("Failed to load games: \(error)")
                }
            }
        }
    }
}
