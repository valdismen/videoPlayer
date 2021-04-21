//
//  ImageView.swift
//  videoPlayer
//

import UIKit

final class ImageView: UIImageView {
    var provider: ImageProviderProtocol? {
        didSet {
            loadImage()
        }
    }

    private func loadImage() {
        provider?.load { [weak self] image in
            self?.image = image
        }
    }
}
