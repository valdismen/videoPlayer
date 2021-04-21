//
//  MainModuleAssembly.swift
//  videoPlayer
//
//

import UIKit

final class MainModuleAssembly {
    func make() -> UIViewController {
        let dataLoader = DataLoader()
        let pagesProvider = VideoPagesProvider(dataLoader: dataLoader)
        return MainViewController(pagesProvider: pagesProvider)
    }
}
