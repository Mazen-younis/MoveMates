import Foundation
import UIKit


class APIService {
    static let shared = APIService()
    let baseURL = "http://127.0.0.1:8000"
    private init() {}

    enum APIError: Error {
        case invalidURL
        case noData
        case invalidResponse
        case decodingError
        case serverError(String)
    }

    
    // MARK: - Fetch All Users
    func fetchUsers(completion: @escaping (Result<[MoveMatesUser], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let users = try JSONDecoder().decode([MoveMatesUser].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Register New User
    func registerUser(user: UserCreateRequest, completion: @escaping (Result<MoveMatesUser, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(NSError(domain: "No response or data", code: 0)))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detail])))
                    return
                }

                let fallbackMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: fallbackMessage])))
                return
            }

            do {
                let createdUser = try JSONDecoder().decode(MoveMatesUser.self, from: data)
                completion(.success(createdUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Login User
    func loginUser(identifier: String, password: String, completion: @escaping (Result<MoveMatesUser, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/login") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginPayload: [String: String] = [
            "username_or_email": identifier,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginPayload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }

            do {
                let user = try JSONDecoder().decode(MoveMatesUser.self, from: data)
                completion(.success(user))
            } catch {
                print("Decoding error: \(error)")
                print("Response body: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
                completion(.failure(error))
            }
        }.resume()
    }


    // MARK: - Update User
    func updateUser(user: MoveMatesUser, completion: @escaping (Result<MoveMatesUser, Error>) -> Void) {
        guard let id = user.id,
              let url = URL(string: "\(baseURL)/users/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let updatedUser = try JSONDecoder().decode(MoveMatesUser.self, from: data)
                completion(.success(updatedUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    
    // MARK: - Fetch Games
    func fetchGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/games") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let games = try JSONDecoder().decode([Game].self, from: data)
                completion(.success(games))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Join Game
    func joinGame(userId: Int, gameId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/participants") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "user_id": userId,
            "game_id": gameId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let data = data,
                   let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detail])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Create Game
    func createGame(game: GameCreateRequest, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/games") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encodedData = try JSONEncoder().encode(game)
            request.httpBody = encodedData
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let serverError = NSError(domain: "Server Error", code: 0, userInfo: nil)
                completion(.failure(serverError))
                return
            }

            do {
                let createdGame = try JSONDecoder().decode(Game.self, from: data)
                completion(.success(createdGame.id))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Request to Join Game
    func requestToJoinGame(userId: Int, gameId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(APIService.shared.baseURL)/participants/request_join/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Int] = [
            "user_id": userId,
            "game_id": gameId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let message = "Failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    
    // MARK: - Approve Join Request
    func approveJoinRequest(requestId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/participants/approve_request/\(requestId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Approval failed"])))
                return
            }

            completion(.success(()))
        }.resume()
    }


    // MARK: - Mark Private Message As Read
    func markPrivateMessageAsRead(messageId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(APIService.shared.baseURL)/private_messages/mark_read/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["message_id": messageId]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }


    // MARK: - Send Private Message
    func sendPrivateMessage(message: MessageCreate, completion: @escaping (Result<Message, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/send") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(message)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let newMessage = try JSONDecoder().decode(Message.self, from: data)
                completion(.success(newMessage))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // MARK: - Fetch Private Chat Summaries
    func fetchPrivateChats(userId: Int, completion: @escaping (Result<[PrivateChatSummary], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/user/\(userId)") else {
            print("Invalid URL")
            completion(.failure(APIError.invalidURL))
            return
        }

        print("Fetching private chats for userId: \(userId) from URL: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid HTTP response")
                completion(.failure(APIError.invalidResponse))
                return
            }

            print("Status code:", httpResponse.statusCode)

            guard let data = data else {
                print("No data received")
                completion(.failure(APIError.invalidResponse))
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("Raw response JSON:\n\(raw)")
            } else {
                print("Could not decode raw response as UTF-8 string.")
            }

            do {
                let chats = try JSONDecoder().decode([PrivateChatSummary].self, from: data)
                print("Successfully decoded \(chats.count) private chat(s).")
                completion(.success(chats))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Get User By Id
    func getUserById(id: Int, completion: @escaping (Result<MoveMatesUser, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let user = try JSONDecoder().decode(MoveMatesUser.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    

    
    // MARK: - Start Private Chat
    func startPrivateChat(userId: Int, gameId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/start_chat/?user_id=\(userId)&game_id=\(gameId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let _ = json["message"] as? String {
                    completion(.success(true))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Update User Profile
    func updateProfile(
        userId: Int,
        bio: String?,
        gender: String?,
        favoriteTimes: [String],
        phoneNumber: String?,
        notificationsEnabled: Bool,
        dateOfBirth: String?,
        sports: [String],
        location: String?,
        profilePictureUrl: String?,
        skillLevel: String?,
        completion: @escaping (Result<MoveMatesUser, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)/profile") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any?] = [
            "bio": bio,
            "gender": gender,
            "favorite_times_to_play": favoriteTimes,
            "phone_number": phoneNumber,
            "notifications_enabled": notificationsEnabled,
            "date_of_birth": dateOfBirth,
            "sports": sports,
            "location": location,
            "profile_picture_url": profilePictureUrl,
            "skill_level": skillLevel
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let updatedUser = try JSONDecoder().decode(MoveMatesUser.self, from: data)
                completion(.success(updatedUser))
            } catch {
                print("Decoding error: \(error)")
                print("Response:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Fetch Games Created By
    func fetchGamesCreatedBy(userId: Int, completion: @escaping (Result<[Game], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/games/created_by/\(userId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let games = try JSONDecoder().decode([Game].self, from: data)
                completion(.success(games))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Get Participants
    func getParticipants(for gameId: Int, completion: @escaping (Result<[MoveMatesUser], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/participants/game/\(gameId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let users = try JSONDecoder().decode([MoveMatesUser].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch Private Conversation
    func fetchConversation(user1: Int, user2: Int, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/\(user1)/\(user2)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let messages = try JSONDecoder().decode([Message].self, from: data)
                completion(.success(messages))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Submit Rating
    func submitRating(raterId: Int, ratedId: Int, rating: Float, feedback: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/rating/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Always include feedback (even if it's an empty string)
        let payload: [String: Any] = [
            "rater_id": raterId,
            "rated_id": ratedId,
            "rating": rating,
            "feedback": feedback ?? ""  // Feedback can be nil; send empty string instead
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to submit rating."])))
                return
            }

            completion(.success(()))
        }.resume()
        
    }
    
    // MARK: - fetch Chat Mates (returns PrivateChatSummary, not full user objects!)
    func fetchChatMates(userId: Int, completion: @escaping (Result<[PrivateChatSummary], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/user/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let mates = try JSONDecoder().decode([PrivateChatSummary].self, from: data)
                completion(.success(mates))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    // MARK: - Fetch User Rating
    func fetchUserRating(userId: Int, completion: @escaping (Result<UserRatingResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/rating/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let rating = try JSONDecoder().decode(UserRatingResponse.self, from: data)
                completion(.success(rating))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    // MARK: - Response struct for user ratings
    struct UserRatingResponse: Codable {
        let average: Double
        let count: Int
    }
    
    // MARK: - Fetch Ratings
    func fetchRatings(for userId: Int, completion: @escaping (Result<(received: [Rating], given: [Rating]), Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/ratings/\(userId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([String: [Rating]].self, from: data)
                let received = decodedData["received"] ?? []
                let given = decodedData["given"] ?? []
                completion(.success((received, given)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Upload Profile Picture
    func uploadProfilePicture(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/upload_profile_picture") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let imageData = image.jpegData(compressionQuality: 0.8)!
        let filename = "profile_\(UUID().uuidString).jpg"

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
                if let urlString = json?["url"] {
                    completion(.success(urlString))
                } else {
                    let errorMsg = json?["detail"] ?? "No URL returned"
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // MARK: - Delete Private Chat
    func deletePrivateChat(currentUserId: Int, recipientId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/private_messages/chat/\(currentUserId)/\(recipientId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete chat."])))
            }
        }.resume()
    }
    
    
    // MARK: - Delete Game
    func deleteGame(gameId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/games/delete/\(gameId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete game."])))
            }
        }.resume()
    }
    
    // MARK: - Fetch join requests for a specific user
    func fetchJoinRequestsForUser(userId: Int, completion: @escaping (Result<[JoinRequest], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/participants/user/\(userId)/join_requests") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let requests = try JSONDecoder().decode([JoinRequest].self, from: data)
                completion(.success(requests))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Fetch Join Requests For Creator
    func fetchJoinRequestsForCreator(userId: Int, completion: @escaping (Result<[JoinRequest], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/participants/creator_join_requests/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let requests = try JSONDecoder().decode([JoinRequest].self, from: data)
                completion(.success(requests))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
}
