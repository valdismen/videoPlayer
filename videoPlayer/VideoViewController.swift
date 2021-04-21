//
//  VideoViewController.swift
//  videoPlayer
//
//

import AVKit

final class VideoViewController: UIViewController {
    private let infoLabel = UILabel()
    
    private let dataLoader = DataLoader()
    private let videoUrl: String
    private var savedVideoUrl: URL?
    
    init(videoUrl: String) {
        self.videoUrl = videoUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureInfo()
        
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
        
        let tapRecogrizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tapRecogrizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc private func onTap() {
        playVideo()
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
    
    private func configureInfo() {
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = .white
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
