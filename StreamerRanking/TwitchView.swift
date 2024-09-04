import SwiftUI

struct TwitchView: View {
    @Binding var streamers: [Streamer]

    var body: some View {
        NavigationView {
            List(streamers) { streamer in
                VStack(alignment: .leading) {
                    HStack {
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
            .navigationTitle("Twitch Rankings")
        }
    }
}
