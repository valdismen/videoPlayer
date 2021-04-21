//
//  VideoViewController.swift
//  videoPlayer
//

import AVKit

final class VideoViewController: UIViewController {
    private let infoLabel = UILabel()
    private let previewView: ImageView = {
        let view = ImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let dataLoader: DataLoaderProtocol
    private let videoUrl: String
    
    private var savedVideoUrl: URL?
    
    init(videoUrl: String, dataLoader: DataLoaderProtocol, previewProvider: ImageProviderProtocol?) {
        self.videoUrl = videoUrl
        self.dataLoader = dataLoader
        previewView.provider = previewProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureView()
        loadVideo()
        
        let tapRecogrizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tapRecogrizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc private func onTap() {
        playVideo()
    }
    
    private func loadVideo() {
        showLoading()
        dataLoader.load(urlString: videoUrl) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.saveVideo(data: data)
                self.showTip(with: "Нажмите, чтобы воспроизвести")
            case .failure(let error):
                self.showError(with: error.text)
            }
        }
    }
    
    private func saveVideo(data: Data) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).mp4")
        try? data.write(to: url)
        savedVideoUrl = url
    }
    
    private func playVideo() {
        guard let savedVideoUrl = savedVideoUrl else {
            return
        }
        
        let player = AVPlayer(url: savedVideoUrl)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: false) {
            player.play()
        }
    }
    
    private func configureView() {
        [previewView, infoLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        infoLabel.textColor = .white
        infoLabel.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func showTip(with text: String) {
        infoLabel.text = text
        showInfo()
    }
    
    private func showError(with text: String) {
        infoLabel.text = text
        showInfo()
    }
    
    private func showLoading() {
        infoLabel.text = "Идёт загрузка видео..."
        showInfo()
    }
    
    private func showInfo() {
        infoLabel.isHidden = false
    }
    
    private func hideInfo() {
        infoLabel.isHidden = true
    }
}
