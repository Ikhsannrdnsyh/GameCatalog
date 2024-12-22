//
//  ImageDownloader.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 11/12/24.
//

import UIKit

class ImageDownloader {

    func downloadImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
        }
        return image
    }
}
