//
//  PagesProvider.swift
//  videoPlayer
//

import UIKit

struct PagesLoadingError: Error {
    let errorText: String
}

typealias PagesLoadingResult = Result<[UIViewController], PagesLoadingError>

protocol PagesProviderProtocol {
    func loadPages(completion: @escaping (PagesLoadingResult) -> Void)
}
