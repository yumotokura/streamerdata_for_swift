import SwiftUI

struct TwitchView: View {
    @Binding var streamers: [Streamer]
    @Binding var isShowingPlatformSelector: Bool // サイドメニュー表示フラグ
    private let api = TwitchAPI() // APIインスタンスを作成

    var body: some View {
        VStack {
            HStack {
                Text("Twitch Streamers")
                    .font(.headline)

                Spacer()

                // データ再ロードボタン
                Button(action: {
                    refreshStreamers() // データを再ロード
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                // サイドメニュー表示ボタン
                Button(action: {
                    // サイドメニューの表示・非表示を切り替え
                    withAnimation {
                        isShowingPlatformSelector.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3") // サイドメニューアイコン
                        .font(.system(size: 18))
                        .padding(6)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            List(streamers) { streamer in
                VStack(alignment: .leading) {
                    HStack {
                        // プロフィール画像を表示
                        AsyncImage(url: URL(string: streamer.profileImageUrl ?? "https://via.placeholder.com/150")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            // 読み込み中はデフォルト画像を表示
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading) {
                            Text(streamer.userName)
                                .font(.headline)
                            Text("Viewers: \(streamer.viewerCount)")
                                .font(.subheadline)
                            Text("Game: \(streamer.gameName)")
                                .font(.subheadline)
                        }
                    }
                    
                    // ストリームのサムネイル画像を表示（thumbnailUrlが必須の場合）
                    let thumbnailUrl = streamer.thumbnailUrl.replacingOccurrences(of: "{width}x{height}", with: "320x180")
                    
                    AsyncImage(url: URL(string: thumbnailUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 180)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 320, height: 180)
                    }

                    // 配信リンクを表示
                    if let url = URL(string: "https://www.twitch.tv/\(streamer.userLogin)") {
                        Link("Watch Stream", destination: url)
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }

    // データリフレッシュ処理
    private func refreshStreamers() {
        api.fetchTopStreamers { fetchedStreamers in
            if let fetchedStreamers = fetchedStreamers {
                DispatchQueue.main.async {
                    streamers = fetchedStreamers
                }
            } else {
                print("Failed to fetch streamers")
            }
        }
    }
}
