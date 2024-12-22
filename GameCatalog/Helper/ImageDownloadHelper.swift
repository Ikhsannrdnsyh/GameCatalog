//
//  ImageDownloadHelper.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 18/12/24.
//

import UIKit

class ImageDownloadHelper {

    private let imageDownloader = ImageDownloader()
    func startDownload(game: Game, completion: @escaping (UIImage?) -> Void) {
        if game.state == .new {
            Task {
                do {
                    guard let imageUrl = game.backgroundImage else { return }

                    let image = try await imageDownloader.downloadImage(url: imageUrl)
                    game.state = .downloaded
                    game.image = image
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } catch {
                    game.state = .failed
                    game.image = nil
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    func startDownloadForCollectionView(game: Game, indexPath: IndexPath, collectionView: UICollectionView) {
        startDownload(game: game) { [weak collectionView] image in
            guard let collectionView = collectionView else { return }
            if let image = image {
                game.image = image
                collectionView.reloadItems(at: [indexPath])
            } else {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    func startDownloadForImageView(game: Game, imageView: UIImageView) {
        startDownload(game: game) { [weak imageView] image in
            imageView?.image = image
        }
    }
}


