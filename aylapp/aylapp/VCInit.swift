//
//  VCInit.swift
//  aylapp
//
//  Created by Berkhan Agar on 25.04.2026.
//

import SwiftUI
import UIKit

final class VCInit: UIHostingController<AylAppView> {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    init() {
        super.init(rootView: AylAppView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AylAppView())
    }
}

struct AylAppView: View {
    var body: some View {
        FilmAlbumView()
    }
}

private enum FilmTheme {
    static let background = Color.black
    static let frame = Color.white.opacity(0.08)
    static let shadow = Color.black.opacity(0.34)
}

private struct FilmPhoto: Identifiable {
    let id: Int

    var assetName: String {
        "img-\(id)"
    }
}

private struct FilmAlbumView: View {
    @State private var currentIndex = 0
    @State private var activeLayers: [SlideLayer] = []
    @State private var incomingOpacity: Double = 1

    private let photos = (1...10).map(FilmPhoto.init)
    private let slideDuration: Double = 4
    private let transitionDuration = 1.2

    var body: some View {
        GeometryReader { _ in
            ZStack {
                FilmTheme.background
                    .ignoresSafeArea()

                ForEach(Array(activeLayers.enumerated()), id: \.element.id) { index, layer in
                    MovingFilmPhotoLayer(
                        assetName: layer.photo.assetName,
                        seed: layer.seed,
                        animationDuration: slideDuration + transitionDuration
                    )
                    .opacity(opacity(for: index))
                }

                FilmTextureOverlay()
            }
        }
        .task {
            guard photos.count > 1 else { return }
            if activeLayers.isEmpty {
                activeLayers = [SlideLayer(photo: photos[0], seed: 0)]
            }
            await runSlideshow()
        }
    }

    private func opacity(for index: Int) -> Double {
        guard activeLayers.count > 1, index == activeLayers.count - 1 else { return 1 }
        return incomingOpacity
    }

    private func runSlideshow() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64(slideDuration * 1_000_000_000))
            let upcoming = (currentIndex + 1) % photos.count

            await MainActor.run {
                activeLayers.append(
                    SlideLayer(
                        photo: photos[upcoming],
                        seed: currentIndex + 1
                    )
                )
                incomingOpacity = 0
                withAnimation(.easeInOut(duration: transitionDuration)) {
                    incomingOpacity = 1
                }
            }

            try? await Task.sleep(nanoseconds: UInt64(transitionDuration * 1_000_000_000))

            await MainActor.run {
                currentIndex = upcoming
                if activeLayers.count > 1 {
                    activeLayers.removeFirst(activeLayers.count - 1)
                }
                incomingOpacity = 1
            }
        }
    }
}

private struct SlideLayer: Identifiable {
    let id = UUID()
    let photo: FilmPhoto
    let seed: Int
}

private struct MovingFilmPhotoLayer: View {
    let assetName: String
    let seed: Int
    let animationDuration: Double

    @State private var progress: CGFloat = 0

    var body: some View {
        FilmPhotoCard(assetName: assetName)
            .scaleEffect(interpolate(from: 1.02, to: targetScale, progress: progress))
            .offset(
                x: interpolate(from: startOffset.width, to: endOffset.width, progress: progress),
                y: interpolate(from: startOffset.height, to: endOffset.height, progress: progress)
            )
            .rotationEffect(.degrees(interpolate(from: startRotation, to: endRotation, progress: progress)))
            .onAppear {
                progress = 0
                withAnimation(.linear(duration: animationDuration)) {
                    progress = 1
                }
            }
    }

    private var targetScale: CGFloat {
        seed.isMultiple(of: 2) ? 1.12 : 1.18
    }

    private var startOffset: CGSize {
        CGSize(
            width: seed.isMultiple(of: 2) ? -8 : 8,
            height: seed.isMultiple(of: 3) ? -6 : 6
        )
    }

    private var endOffset: CGSize {
        CGSize(
            width: seed.isMultiple(of: 2) ? 18 : -18,
            height: seed.isMultiple(of: 3) ? 14 : -14
        )
    }

    private var startRotation: Double {
        seed.isMultiple(of: 2) ? -0.4 : 0.4
    }

    private var endRotation: Double {
        seed.isMultiple(of: 2) ? -1.1 : 1.1
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }

    private func interpolate(from: Double, to: Double, progress: CGFloat) -> Double {
        from + (to - from) * Double(progress)
    }
}

private struct FilmPhotoCard: View {
    let assetName: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                photoView
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(0.12),
                        .clear,
                        .black.opacity(0.45)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var photoView: some View {
        if UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.17, green: 0.10, blue: 0.08),
                        Color(red: 0.04, green: 0.04, blue: 0.05),
                        Color(red: 0.10, green: 0.08, blue: 0.13)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(.white.opacity(0.7))

                    Text(assetName)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.86))

                    Text("Assets.xcassets icine bu adla ekle")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))
                }
            }
        }
    }
}

private struct FilmTextureOverlay: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FilmPerforationRow()
                Spacer()
                FilmPerforationRow()
            }
            .padding(.vertical, 12)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.65),
                            .clear,
                            .clear,
                            .black.opacity(0.78)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 0)
                .stroke(FilmTheme.frame, lineWidth: 1)
                .padding(.horizontal, 18)
                .padding(.vertical, 42)
                .shadow(color: FilmTheme.shadow, radius: 20)
        }
        .allowsHitTesting(false)
    }
}

private struct FilmPerforationRow: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<12, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(.black.opacity(0.88))
                    .frame(width: 22, height: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(.white.opacity(0.06), lineWidth: 0.5)
                    )
            }
        }
    }
}
