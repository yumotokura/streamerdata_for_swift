import SwiftUI

struct ContentView: View {
    @State private var streamers: [Streamer] = []
    @State private var isShowingPlatformSelector = false
    @State private var dragOffset: CGSize = .zero
    @State private var currentView: ViewType = .topStreamers

    var body: some View {
        ZStack(alignment: .trailing) {
            // 現在表示するビューを管理
            switch currentView {
            case .topStreamers:
                StreamerListView(streamers: $streamers, isShowingPlatformSelector: $isShowingPlatformSelector)
                    .onAppear {
                        fetchStreamers() // データを取得
                    }
            case .twitch:
                TwitchView(streamers: $streamers, isShowingPlatformSelector: $isShowingPlatformSelector)
                    .onAppear {
                        fetchStreamers() // 同じデータを取得
                    }
            }

            // サイドメニュー
            if isShowingPlatformSelector {
                PlatformSelectorView(
                    isShowing: $isShowingPlatformSelector,
                    currentView: $currentView,
                    streamers: $streamers
                )
                .frame(width: UIScreen.main.bounds.width / 2)
                .background(Color.white)
                .offset(x: dragOffset.width > 0 ? dragOffset.width : 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 0 {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width > UIScreen.main.bounds.width / 6 {
                                    isShowingPlatformSelector = false
                                }
                                dragOffset = .zero
                            }
                        }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -100 {
                        withAnimation {
                            isShowingPlatformSelector = true
                        }
                    }
                }
        )
    }

    private func fetchStreamers() {
        let api = TwitchAPI()
        api.fetchTopStreamers { streamers in
            if let streamers = streamers {
                DispatchQueue.main.async {
                    self.streamers = streamers
                }
            } else {
                print("Failed to fetch streamers")
            }
        }
    }
}

enum ViewType {
    case topStreamers
    case twitch
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
