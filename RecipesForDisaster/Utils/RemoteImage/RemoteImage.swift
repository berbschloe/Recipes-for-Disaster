//
//  RemoteImage.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/25/25.
//

import SwiftUI

struct RemoteImage<Content: View>: View {
    
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    @StateObject private var viewModel = ViewModel()
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(viewModel.phase)
                .task(id: url) {
                    await viewModel.loadImage(
                        url: url,
                        targetSize: geometry.size
                    )
                }
        }
    }
}

extension RemoteImage {
    init<I, P>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.init(url: url) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

private let blankImage = Image(uiImage: UIImage())
                               
extension RemoteImage {
    init(url: URL?) where Content == Image {
        self.init(url: url) { phase in
            phase.image ?? blankImage
        }
    }
}
