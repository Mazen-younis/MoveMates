import Foundation

struct Game: Codable, Identifiable, Hashable {
    let id: Int
    let sport: String
    let location: String
    let date: String
    let needed_players: Int
    let skill_level: String
    let gender_preference: String
    let is_public: Bool
    let creator_id: Int
    let created_at: String
    
    enum CodingKeys: String, CodingKey {
        case id, sport, location, date
        case needed_players = "needed_players"
        case skill_level = "skill_level"
        case gender_preference = "gender_preference"
        case is_public = "is_public"
        case creator_id = "creator_id"
        case created_at = "created_at"
    }
}

