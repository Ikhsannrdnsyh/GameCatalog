//
//  DetailViewController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 11/12/24.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var released: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var namePlatform: UILabel!
    @IBOutlet weak var requirement: UITextView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var recommendReq: UITextView!
    @IBOutlet weak var imageGame: UIImageView!
    @IBOutlet weak var titleGame: UILabel!

    var game: Game?
    var detailGame: PlatformData?
    var requirementGame: Requirements?
    private let imageDownloaderHelper = ImageDownloadHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        config()
        configFavorite()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let game = game else { return }
        DataService().isFavorite(game.id) { [weak self] isFavorite in
            self?.updateHeartIcon(isFavorite: isFavorite)
        }
    }
    private func setupUI() {
        detailView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        titleGame.textColor = .white
        titleGame.backgroundColor = .systemBlue
        titleGame.layer.cornerRadius = 10
        titleGame.layer.masksToBounds = true

        imageGame.layer.cornerRadius = 5
        imageGame.clipsToBounds = true

        imageGame.layer.borderWidth = 5
        imageGame.layer.borderColor = UIColor.init(hex: "FF6500").cgColor
    }

    private func config() {
        guard let game = game else { return }

        titleGame.text = game.name
        if let releaseDate = game.released {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        released.text = dateFormatter.string(from: releaseDate)
                    } else {
                        released.text = "Unknown"
                    }

        rating.text = String(game.rating)
        namePlatform.text = detailGame?.platform.name

        if let requirementGame = requirementGame {
            requirement.attributedText = requirementGame.minimum?.htmlToAttributedString(label: requirement) ?? NSAttributedString(string: "No minimum requirements available")
            recommendReq.attributedText = requirementGame.recommended?.htmlToAttributedString(label: recommendReq) ?? NSAttributedString(string: "No recommended requirements available")
        } else {
            requirement.text = "No requirements available"
            recommendReq.text = "No recommended requirements available"
        }
        requirement.isEditable = false
        recommendReq.isEditable = false

        imageGame.image = game.image

        if game.state == .new {
            indicatorLoading.isHidden = false
            indicatorLoading.startAnimating()
            imageDownloaderHelper.startDownloadForImageView(game: game, imageView: imageGame)
        } else {
            indicatorLoading.stopAnimating()
            indicatorLoading.isHidden = true
        }

    }
    private func configFavorite() {
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(didTapFavoriteButton)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }
    @objc
    private func didTapFavoriteButton() {
        guard let game = game else { return }
        DataService().isFavorite(game.id) { isFavorite in
            if isFavorite {
                DataService().deleteFavorite(game.id) { success in
                    if success {
                        self.updateHeartIcon(isFavorite: false)
                    } else {
                        print("Failed to remove from favorites")
                    }
                }
            } else {
                let gameFav = Game(
                    id: game.id,
                    name: game.name,
                    released: game.released,
                    rating: game.rating,
                    platforms: game.platforms,
                    backgroundImage: game.backgroundImage,
                    state: game.state,
                    isFavorite: true
                )
                DataService().saveFavorite(gameFav) { success in
                    if success {
                        self.updateHeartIcon(isFavorite: true)
                    } else {
                        print("Failed to add to Favorites")
                    }
                }
            }
        }
    }
    func updateHeartIcon(isFavorite: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
                style: .plain,
                target: self,
                action: #selector(self.didTapFavoriteButton)
            )
        }
    }
}
