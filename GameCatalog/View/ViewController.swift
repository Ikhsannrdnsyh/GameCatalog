//
//  ViewController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 10/12/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var filteredData: [Game] = []
    private var games: [Game] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        config()
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "List of Game"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: collectionView.frame.width - 20, height: 150)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0

        let attributeText = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributeText

        collectionView.collectionViewLayout = layout

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GameListViewCell", bundle: nil), forCellWithReuseIdentifier: "gameListViewCell")
    }

    private func config() {
        self.collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GameListViewCell", bundle: nil), forCellWithReuseIdentifier: "gameListViewCell")

        filteredData = []

        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await getGames() }
    }

    func getGames() async {
        let network = NetworkService()
        do {
            games = try await network.getGames()

            filteredData = games
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }

    var sortGames: [Game] {
        return filteredData.sorted { $0.rating > $1.rating }
    }

    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameListViewCell", for: indexPath) as? GameListViewCell {
            let sortedGame = sortGames
            let game = sortedGame[indexPath.row]

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
                startDownload(game: game, indexPath: indexPath)
            } else {
                cell.indicatorLoading.stopAnimating()
                cell.indicatorLoading.isHidden = true
            }

            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    fileprivate func startDownload(game: Game, indexPath: IndexPath) {
        let imageDownloader = ImageDownloader()
        if game.state == .new {
            Task {
                do {
                    guard let imageUrl = game.backgroundImage else { return }

                    let image = try await imageDownloader.downloadImage(url: imageUrl)
                    game.state = .downloaded
                    game.image = image

                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                } catch {
                    game.state = .failed
                    game.image = nil
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected list on: ", indexPath.row)
        let data = sortGames
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
