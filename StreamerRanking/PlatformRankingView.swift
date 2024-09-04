import SwiftUI

struct PlatformRankingView: View {
    let platformName: String

    var body: some View {
        Text("\(platformName) のランキング")
            .navigationTitle("\(platformName) Rankings")
    }
}
