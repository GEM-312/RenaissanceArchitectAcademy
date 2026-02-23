import SwiftUI

/// Displays a science icon - uses custom image if available, SF Symbol as fallback
struct ScienceIconView: View {
    let science: Science
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: science.sfSymbolName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(RenaissanceColors.color(for: science))
            .frame(width: size, height: size)
    }
}

/// Displays a building state icon
struct BuildingStateIcon: View {
    let state: BuildingState
    var size: CGFloat = 60

    var body: some View {
        Image(state.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

/// Displays a navigation icon
struct NavIconView: View {
    enum NavIcon: String {
        case back = "NavBack"
        case close = "NavClose"
        case correct = "NavCorrect"
        case home = "NavHome"
        case info = "NavInfo"
        case settings = "NavSettings"
    }

    let icon: NavIcon
    var size: CGFloat = 44

    var body: some View {
        Image(icon.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

/// Displays a city/era image
struct CityImageView: View {
    let era: Era
    var height: CGFloat = 200

    var body: some View {
        Image(era.cityImageName)
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .clipped()
    }
}

#Preview("Science Icons") {
    VStack(spacing: 20) {
        Text("Science Icons")
            .font(.custom("Mulish-Light", size: 24))

        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
            ForEach(Science.allCases, id: \.self) { science in
                VStack {
                    ScienceIconView(science: science, size: 50)
                    Text(science.rawValue)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
        }
    }
    .padding()
    .background(RenaissanceColors.parchment)
}

#Preview("Building States") {
    HStack(spacing: 20) {
        ForEach(BuildingState.allCases, id: \.self) { state in
            VStack {
                BuildingStateIcon(state: state)
                Text(state.rawValue)
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(RenaissanceColors.parchment)
}

#Preview("Navigation Icons") {
    HStack(spacing: 20) {
        NavIconView(icon: .back)
        NavIconView(icon: .home)
        NavIconView(icon: .settings)
        NavIconView(icon: .info)
        NavIconView(icon: .close)
        NavIconView(icon: .correct)
    }
    .padding()
    .background(RenaissanceColors.parchment)
}
