//
//  VideoPageModuleAssembly.swift
//  videoPlayer
//

import UIKit

final class VideoPageModuleAssembly {
    func make(videoUrl: String, previewUrl: String) -> UIViewController {
        return VideoViewController(
            videoUrl: videoUrl,
            dataLoader: DataLoader(),
            previewProvider: makePreviewProvider(previewUrl: previewUrl)
        )
    }
    
    private func makePreviewProvider(previewUrl: String) -> ImageProviderProtocol? {
        guard let url = URL(string: previewUrl) else { return nil }
        return ImageProviderUrl(url: url)
    }
}
