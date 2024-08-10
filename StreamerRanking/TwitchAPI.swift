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
    
    // 日本のトップストリーマー情報を取得するメソッド
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
                        let decodedResponse = try JSONDecoder().decode(TwitchResponse.self, from: data)
                        completion(decodedResponse.data)
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion(nil)
                }
            }
            
            task.resume()
        }
    }
}
