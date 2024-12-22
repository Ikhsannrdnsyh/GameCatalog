//
//  SearchController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 16/12/24.
//

import Foundation
import UIKit

class SearchController: UIViewController {
    private var filteredData: [Game] = []
    private var games: [Game] = []
    private let imageDownloadHelper = ImageDownloadHelper()
    @IBOutlet weak var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchEnabled: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    override func viewDidLoad() {
        setupUI()
        config()
    }
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Search Game"
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
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Games"
        navigationItem.searchController = searchController
        searchController.searchBar.searchTextField.backgroundColor = UIColor.white
    }
    private func config() {
        collectionView.delegate = self
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
            filteredData = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredData = []
            collectionView.reloadData()
            return
        }
        filteredData = games.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        collectionView.reloadData()
    }
}

extension SearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameListViewCell", for: indexPath) as? GameListViewCell {
            let game = filteredData[indexPath.row]
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
                imageDownloadHelper.startDownloadForCollectionView(game: filteredData[indexPath.row], indexPath: indexPath, collectionView: collectionView)
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

extension SearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected list on: ", indexPath.row)
        let selectedGame = filteredData[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        vc.game = selectedGame
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.navigationItem.title = "Detail"
        navigationController?.pushViewController(vc, animated: true)
    }
}
