//
//  MainViewController.swift
//  videoPlayer
//

import UIKit

final class MainViewController: UIPageViewController {
    
    private var pagesList: [UIViewController]?
    
    private let infoLabel = UILabel()
    
    private let pagesProvider: PagesProviderProtocol
    
    init(pagesProvider: PagesProviderProtocol) {
        self.pagesProvider = pagesProvider
        
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        
        configureInfo()
        showLoading()
        
        pagesProvider.loadPages { [weak self] in
            self?.loadingComplete(result: $0)
        }
    }
    
    private func configureInfo() {
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadingComplete(result: PagesLoadingResult) {
        hideInfo()
        switch result {
        case .success(let pages):
            loadingSuccess(pages: pages)
        case .failure(let error):
            loadingError(error: error)
        }
    }
    
    private func loadingSuccess(pages: [UIViewController]) {
        view.isUserInteractionEnabled = true
        setViewControllers([pages.first].compactMap { $0 }, direction: .forward, animated: false, completion: nil)
        pagesList = pages
    }
    
    private func loadingError(error: PagesLoadingError) {
        showError(with: error.errorText)
    }
    
    private func showError(with text: String) {
        infoLabel.text = text
        showInfo()
    }
    
    private func showLoading() {
        infoLabel.text = "Идёт загрузка данных..."
        showInfo()
    }
    
    private func showInfo() {
        infoLabel.isHidden = false
    }
    
    private func hideInfo() {
        infoLabel.isHidden = true
    }
}

extension MainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pagesList = pagesList,
              let controllerIndex = pagesList.firstIndex(of: viewController) else {
            return nil
        }
        
        let newIndex = controllerIndex - 1
        
        guard newIndex >= 0 else {
            return pagesList.last
        }
        
        return pagesList[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pagesList = pagesList,
              let controllerIndex = pagesList.firstIndex(of: viewController) else {
            return nil
        }
        
        let newIndex = controllerIndex + 1
        
        guard newIndex < pagesList.count else {
            return pagesList.first
        }
        
        return pagesList[newIndex]
    }
}

