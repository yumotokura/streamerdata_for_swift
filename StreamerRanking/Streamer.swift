import Foundation

// Streamer情報を扱う構造体
struct Streamer: Identifiable, Decodable {
    var id: String { userId }
    let userId: String
    let userName: String
    let userLogin: String
    let viewerCount: Int
    var profileImageUrl: String? // プロフィール画像のURL
    let thumbnailUrl: String // ストリームのサムネイル画像のURL
    let gameName: String // ゲーム名

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userLogin = "user_login"
        case viewerCount = "viewer_count"
        case profileImageUrl = "profile_image_url"
        case thumbnailUrl = "thumbnail_url"
        case gameName = "game_name"
    }
}

// Twitch APIからのストリーマー一覧のレスポンス
struct TwitchResponse: Decodable {
    var data: [Streamer] // ここをletからvarに変更して、後で変更可能にする
}

// Twitch APIエラーレスポンスを扱う構造体
struct TwitchErrorResponse: Decodable {
    let error: String
    let status: Int
    let message: String
}

// UserInfoを扱う構造体（ユーザー情報）
struct UserInfo: Decodable {
    let id: String
    let login: String
    let displayName: String
    let profileImageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case displayName = "display_name"
        case profileImageUrl = "profile_image_url"
    }
}

// Twitch APIからのユーザー情報レスポンス
struct UserInfoResponse: Decodable {
    let data: [UserInfo]
}
