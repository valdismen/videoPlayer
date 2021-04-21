//
//  ImageProvider.swift
//  videoPlayer
//

import UIKit

typealias ImageCompletion = (UIImage?) -> Void

protocol ImageProviderProtocol {
    func load(completion: @escaping ImageCompletion)
}

final class ImageProviderUrl: ImageProviderProtocol {
    private let url: URL
    private var completionBlock: ImageCompletion?

    init(url: URL) {
        self.url = url
    }

    func load(completion: @escaping ImageCompletion) {
        completionBlock = completion

        DispatchQueue.global().async {
            self.startLoading()
        }
    }

    private func startLoading() {
        let data = try? Data(contentsOf: url)
        guard let imageData = data else {
            callCompletion(with: nil)
            return
        }

        let image = UIImage(data: imageData)
        callCompletion(with: image)
    }

    private func callCompletion(with image: UIImage?) {
        DispatchQueue.main.async { self.completionBlock?(image) }
    }
}
