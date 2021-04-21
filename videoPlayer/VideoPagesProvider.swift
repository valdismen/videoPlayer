//
//  VideoPagesProvider.swift
//  videoPlayer
//

import Foundation

final class VideoPagesProvider: PagesProviderProtocol {
    
    private let dataUrl = "https://89.208.230.255/test/item"
    
    private let dataLoader: DataLoaderProtocol
    
    init(dataLoader: DataLoaderProtocol) {
        self.dataLoader = dataLoader
    }
    
    func loadPages(completion: @escaping (PagesLoadingResult) -> Void) {
        dataLoader.load(urlString: dataUrl) { [weak self] result in
            switch result {
            case .success(let data):
                self?.loadingSuccess(completion: completion, data: data)
            case .failure(let error):
                completion(.failure(PagesLoadingError(errorText: error.text)))
            }
        }
    }
    
    private func loadingSuccess(completion: @escaping (PagesLoadingResult) -> Void, data: Data) {
        guard let (preview, videos) = extractUrls(data: data) else {
            completion(.failure(PagesLoadingError(errorText: "Получен некорректный ответ от сервера")))
            return
        }
        
        completion(.success(videos.map({
            VideoPageModuleAssembly().make(videoUrl: $0, previewUrl: preview)
        })))
    }
    
    private func extractUrls(data: Data) -> (preview: String, videos: [String])? {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = dictionary["results"] as? [String: String],
              let preview = results["preview_image"] else {
            return nil
        }
        
        let videos = [
            results["single"],
            results["split_v"],
            results["split_h"],
            results["src"]
        ].compactMap { $0 }
        
        return (preview: preview, videos: videos)
    }
}
