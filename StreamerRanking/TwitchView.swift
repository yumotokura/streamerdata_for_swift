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
                    refreshStreamers() // 個別にデータを再ロード
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
                        // 配信者のアイコンを表示
                        AsyncImage(url: URL(string: streamer.profileImageUrl.replacingOccurrences(of: "{width}x{height}", with: "150x150"))) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
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
                    if let url = URL(string: "https://www.twitch.tv/\(streamer.userLogin)") {
                        Link("Watch Stream", destination: url)
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    // 個別のデータリフレッシュ処理
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
