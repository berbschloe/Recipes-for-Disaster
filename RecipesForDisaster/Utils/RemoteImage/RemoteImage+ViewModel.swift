//
//  RemoteImage+ViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/25/25.
//

import Foundation
import Combine
import SwiftUI

extension RemoteImage {
    @MainActor final class ViewModel: ObservableObject {
        
        private let loader: RemoteImageLoader = .shared
        
        @Published private(set) var phase: AsyncImagePhase = .empty
        
        func loadImage(url: URL?, targetSize: CGSize? = nil) async {
            guard let url = url else {
                phase = .empty
                return
            }
            
            do {
                let uiImage = try await loader.loadImage(url: url, targetSize: targetSize)
                phase = .success(Image(uiImage: uiImage))
            } catch {
                phase = .failure(error)
            }
        }
    }
}
