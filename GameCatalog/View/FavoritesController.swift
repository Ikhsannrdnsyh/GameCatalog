//
//  FavoritesController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 16/12/24.
//

import UIKit

class FavoritesController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var favoriteGame: [Game] = []
    private let imageDownloadHelper = ImageDownloadHelper()
    private var messageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFavorite()
        setupGesture()
    }
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: collectionView.frame.width - 20, height: 150)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GameListViewCell", bundle: nil), forCellWithReuseIdentifier: "gameListViewCell")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Favorites"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        let attributeText = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributeText
        messageLabel = UILabel()
        messageLabel.text = "Add to Favorites"
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.textColor = .gray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        messageLabel.isHidden = true
    }
    private func loadFavorite() {
        DataService().loadAllFavorites { [weak self] games in
            guard let self = self else { return }
            self.favoriteGame = games
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.messageLabel.isHidden = !self.favoriteGame.isEmpty
            }
        }
    }
    private func setupGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeForDelete(_:)))
        swipe.direction = .left
        collectionView.addGestureRecognizer(swipe)
    }
    @objc
    private func handleSwipeForDelete(_ gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location),
              let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform(translationX: -100, y: 0)
        }, completion: { [weak self] _ in
            self?.showDeleteConfirmation(for: indexPath)
            UIView.animate(withDuration: 0.3) {
                cell.transform = .identity
            }
        })
    }
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Game",
            message: "Are you sure you want to remove this game from favorites?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.removeFavorite(at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func removeFavorite(at indexPath: IndexPath) {
        let gameToRemove = favoriteGame[indexPath.row]
        DataService().deleteFavorite(gameToRemove.id) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.favoriteGame.remove(at: indexPath.row)
                    self?.collectionView.deleteItems(at: [indexPath])
                } else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to remove the game from favorites.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
extension FavoritesController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteGame.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameListViewCell", for: indexPath) as? GameListViewCell {
            let game = favoriteGame[indexPath.item]
            cell.titleGame.text = game.name
            if let releaseDate = game.released {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                cell.releaseDate.text = dateFormatter.string(from: releaseDate)
            } else {
                cell.releaseDate.text = "Unknown"
            }
            cell.ratingGame.text = String(game.rating)
            cell.gameImage.image = game.image
            if game.state == .new {
                cell.indicatorLoading.isHidden = false
                cell.indicatorLoading.startAnimating()
                imageDownloadHelper.startDownloadForCollectionView(game: favoriteGame[indexPath.item], indexPath: indexPath, collectionView: collectionView)
            } else {
                cell.indicatorLoading.stopAnimating()
                cell.indicatorLoading.isHidden = true
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension FavoritesController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = favoriteGame
        let selectedGame = data[indexPath.row]
        _ = selectedGame.platforms.map { $0.platform.name }.joined(separator: "")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        vc.game = selectedGame
        vc.detailGame = selectedGame.platforms.first
        vc.requirementGame = selectedGame.platforms.first?.requirementsEn
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.navigationItem.title = "Detail"
        navigationController?.pushViewController(vc, animated: true)
    }
}
