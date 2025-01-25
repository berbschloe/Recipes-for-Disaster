//
//  CachedAsyncImage.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/23/25.
//

import SwiftUI
import Foundation

@MainActor
struct CachedAsyncImage<Content: View>: View {
    
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    @StateObject private var loader = CachedImageLoader()
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(loader.phase)
            .task(id: url) {
                await loader.loadImage(url: url)
            }
    }
}

@MainActor
extension CachedAsyncImage {
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

@MainActor
final class CachedImageLoader: ObservableObject {
    
    private static var cache: [URL: UIImage] = [:]
    
    private let session: URLSession
    
    @Published private(set) var phase: AsyncImagePhase = .empty
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 0,
            diskCapacity: 100 * 1024 * 1024
        )
        
        self.session = URLSession(configuration: configuration)
    }
    
    func loadImage(url: URL?) async {
        guard let url else {
            phase = .empty
            return
        }
        
        if case .failure = phase {
            phase = .empty
        }
        
        if let uiImage = Self.cache[url] {
            phase = .success(Image(uiImage: uiImage))
            return
        }
        
        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let (data, response) = try await session.data(for: request)
            guard let uiImage = await UIImage.decode(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            Self.cache[url] = uiImage
            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}
