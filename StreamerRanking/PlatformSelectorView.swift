import SwiftUI

struct PlatformSelectorView: View {
    @Binding var isShowing: Bool
    @Binding var currentView: ViewType
    @Binding var streamers: [Streamer]
    let platforms = ["Top Streamers", "Twitch", "YouTube", "OPENREC", "その他"]

    var body: some View {
        VStack {
            // サイドメニューを閉じるボタンを追加
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isShowing = false // サイドメニューを閉じる
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            // プラットフォームリスト
            List(platforms, id: \.self) { platform in
                if platform == "Top Streamers" {
                    Button(action: {
                        currentView = .topStreamers
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Text(platform)
                    }
                } else if platform == "Twitch" {
                    Button(action: {
                        currentView = .twitch
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Text(platform)
                    }
                } else {
                    NavigationLink(destination: PlatformRankingView(platformName: platform)) {
                        Text(platform)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        withAnimation {
                            isShowing = false
                        }
                    })
                }
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
    }
}
