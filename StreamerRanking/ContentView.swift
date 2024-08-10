import SwiftUI

struct ContentView: View {
    @State private var streamers: [Streamer] = []

    var body: some View {
        NavigationView {
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
                            // 配信者の名前と視聴者数を表示
                            Text(streamer.userName)
                                .font(.headline)
                            Text("Viewers: \(streamer.viewerCount)")
                                .font(.subheadline)
                            Text("Game: \(streamer.gameName)")
                                .font(.subheadline)
                        }
                    }
                    // 配信リンクを表示
                    if let url = URL(string: "https://www.twitch.tv/\(streamer.userLogin)") {
                        Link("Watch Stream", destination: url)
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Top Streamers")
            .onAppear {
                let api = TwitchAPI()
                api.fetchTopStreamers { streamers in
                    if let streamers = streamers {
                        DispatchQueue.main.async {
                            print("Fetched \(streamers.count) streamers") // デバッグ用
                            self.streamers = streamers
                        }
                    } else {
                        print("Failed to fetch streamers")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
