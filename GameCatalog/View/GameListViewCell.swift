//
//  GameListViewCell.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 10/12/24.
//

import UIKit

class GameListViewCell: UICollectionViewCell {

    @IBOutlet weak var card: UIView!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var ratingGame: UILabel!
    @IBOutlet var releaseDate: UILabel!
    @IBOutlet var titleGame: UILabel!
    @IBOutlet var gameImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()

    }

    private func setupUI() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.opacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4

        card.layer.cornerRadius = 10
        card.layer.masksToBounds = true

        gameImage.layer.cornerRadius = 5
        gameImage.clipsToBounds = true
        gameImage.layer.borderWidth = 3
        gameImage.layer.borderColor = UIColor.white.cgColor

        titleGame.textColor = .white
        titleGame.textAlignment = .center
        titleGame.backgroundColor = .systemBlue
        titleGame.layer.cornerRadius = 10
        titleGame.layer.masksToBounds = true

        ratingGame.textColor = .white
        ratingGame.font = UIFont.systemFont(ofSize: 24, weight: .bold)

        releaseDate.textColor = .white
        releaseDate.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}
