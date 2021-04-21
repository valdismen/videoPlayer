//
//  DataLoader.swift
//  videoPlayer
//

import Foundation

enum DataLoaderError: Error {
    case network
    case notFound
    case serverError
    case wrongUrl
    case noData
    
    var text: String {
        switch self {
        case .network:
            return "Нет соединения с интернетом"
        case .noData:
            return "Не удалось загрузить данные"
        case .notFound:
            return "Данные не найдены"
        case .serverError:
            return "Ошибка сервера"
        case .wrongUrl:
            return "Некорректный URL адрес"
        }
    }
}

typealias DataLoaderCompletion = (Result<Data, DataLoaderError>) -> Void

protocol DataLoaderProtocol {
    func load(urlString: String, completion: @escaping DataLoaderCompletion)
}

final class DataLoader: NSObject, DataLoaderProtocol {
    private let mainQueue = DispatchQueue.main
    
    func load(urlString: String, completion: @escaping DataLoaderCompletion) {
        guard let url = URL(string: urlString) else {
            callOnMainQueue(block: completion, result: .failure(.wrongUrl))
            return
        }
        
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        urlSession.dataTask(with: url) { [weak self] data, response, _ in
            self?.onComplete(completion: completion, data: data, response: response)
        }.resume()
    }
    
    private func onComplete(completion: @escaping DataLoaderCompletion,
                            data: Data?,
                            response: URLResponse?) {
        guard let response = response else {
            callOnMainQueue(block: completion, result: .failure(.network))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            callOnMainQueue(block: completion, result: .failure(.serverError))
            return
        }
        
        if httpResponse.statusCode == 404 {
            callOnMainQueue(block: completion, result: .failure(.notFound))
            return
        }
        
        if httpResponse.statusCode == 500 {
            callOnMainQueue(block: completion, result: .failure(.serverError))
            return
        }
        
        guard let data = data else {
            callOnMainQueue(block: completion, result: .failure(.noData))
            return
        }
        
        callOnMainQueue(block: completion, result: .success(data))
    }
    
    private func callOnMainQueue(block: @escaping DataLoaderCompletion,
                                 result: Result<Data, DataLoaderError>) {
        mainQueue.async { block(result) }
    }
}

extension DataLoader: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
