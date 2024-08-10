import Foundation

struct Streamer: Identifiable, Decodable {
    var id: String { userId }
    let userId: String
    let userName: String
    let userLogin: String
    let viewerCount: Int
    let profileImageUrl: String
//    let title: String  // 配信タイトル
    let gameName: String // ゲーム名

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userLogin = "user_login"
        case viewerCount = "viewer_count"
        case profileImageUrl = "thumbnail_url"
//        case title = "title" // 配信タイトル
        case gameName = "game_name" // ゲーム名
    }
}

struct TwitchResponse: Decodable {
    let data: [Streamer]
}

struct TwitchErrorResponse: Decodable {
    let error: String
    let status: Int
    let message: String
}
