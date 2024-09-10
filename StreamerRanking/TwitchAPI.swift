import Foundation

class TwitchAPI {
    private let clientId = ""
    private let clientSecret = ""
    private var accessToken = ""
    private let tokenUrl = "https://id.twitch.tv/oauth2/token"

    // アクセストークンを取得するメソッド
    func fetchAccessToken(completion: @escaping (Bool) -> Void) {
        var urlComponents = URLComponents(string: tokenUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: "client_credentials")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching token: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let token = jsonResponse?["access_token"] as? String {
                    self.accessToken = token
                    print("Access token: \(token)")
                    completion(true)
                } else {
                    print("Invalid token response: \(jsonResponse ?? [:])")
                    completion(false)
                }
            } catch {
                print("Error decoding token response: \(error)")
                completion(false)
            }
        }
        
        task.resume()
    }
    
    // 日本のトップストリーマー情報を取得し、プロフィール画像を追加するメソッド
    func fetchTopStreamers(completion: @escaping ([Streamer]?) -> Void) {
        fetchAccessToken { success in
            guard success else {
                completion(nil)
                return
            }
            
            // 日本の配信に絞った上で、最大50人のストリーマー情報を取得
            let url = URL(string: "https://api.twitch.tv/helix/streams?first=50&language=ja")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue(self.clientId, forHTTPHeaderField: "Client-Id")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                
                print("Response Data: \(String(data: data, encoding: .utf8)!)")
                
                do {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        let errorResponse = try JSONDecoder().decode(TwitchErrorResponse.self, from: data)
                        print("Error response: \(errorResponse)")
                        completion(nil)
                    } else {
                        var decodedResponse = try JSONDecoder().decode(TwitchResponse.self, from: data)
                        
                        // 各ストリーマーのユーザー情報を取得してプロフィール画像を追加
                        let dispatchGroup = DispatchGroup()

                        for (index, streamer) in decodedResponse.data.enumerated() {
                            dispatchGroup.enter()
                            self.fetchUserInfo(userId: streamer.userId) { userInfo in
                                if let userInfo = userInfo {
                                    decodedResponse.data[index].profileImageUrl = userInfo.profileImageUrl
                                } else {
                                    decodedResponse.data[index].profileImageUrl = "https://via.placeholder.com/150" // デフォルトの画像
                                }
                                dispatchGroup.leave()
                            }
                        }

                        // 全てのプロフィール画像の取得が完了したらコールバックを呼ぶ
                        dispatchGroup.notify(queue: .main) {
                            completion(decodedResponse.data)
                        }
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion(nil)
                }
            }
            
            task.resume()
        }
    }

    // ユーザーIDからプロフィール画像を含むユーザー情報を取得するメソッド
    private func fetchUserInfo(userId: String, completion: @escaping (UserInfo?) -> Void) {
        let url = URL(string: "https://api.twitch.tv/helix/users?id=\(userId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(self.clientId, forHTTPHeaderField: "Client-Id")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching user info: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(UserInfoResponse.self, from: data)
                completion(decodedResponse.data.first)
            } catch {
                print("Error decoding user info: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}
