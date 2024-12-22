//
//  GameListModel.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 10/12/24.
//

import UIKit

enum DownloadState {
    case new, downloaded, failed
}

class Game {
    let id: Int32
    let name: String
    let released: Date?
    let rating: Double
    let platforms: [PlatformData]
    let backgroundImage: URL?

    var image: UIImage?
    var state: DownloadState = .new
    var isFavorite: Bool = false

    init(id: Int32, name: String, released: Date?, rating: Double, platforms: [PlatformData], backgroundImage: URL?, image: UIImage? = nil, state: DownloadState, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.released = released
        self.rating = rating
        self.platforms = platforms
        self.backgroundImage = backgroundImage
        self.image = image
        self.state = state
        self.isFavorite = isFavorite
    }

}
struct Games: Codable {
    let results: [GamesData]
}

struct GamesData: Codable {
    let id: Int32
    let name: String
    let released: Date?
    let rating: Double
    let platforms: [PlatformData]
    let backgroundImage: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case released
        case rating
        case platforms
        case backgroundImage = "background_image"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int32.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)

        let dateString = try? container.decode(String.self, forKey: .released)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        released = dateFormatter.date(from: dateString!)

        self.rating = try container.decode(Double.self, forKey: .rating)
        self.platforms = try container.decode([PlatformData].self, forKey: .platforms)

        let path = try container.decode(String.self, forKey: .backgroundImage)
        backgroundImage = URL(string: path)!

    }
}

struct PlatformData: Codable {
    let platform: PlatformDetail
    let requirementsEn: Requirements?

    enum CodingKeys: String, CodingKey {
        case platform
        case requirementsEn = "requirements_en"
    }

}

struct PlatformDetail: Codable {
    let id: Int
    let name: String
    let slug: String
    let image: String?
    let yearEnd: Int?
    let yearStart: Int?
    let gamesCount: Int?
    let imageBackground: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case image
        case yearEnd = "year_end"
        case yearStart = "year_start"
        case gamesCount = "games_count"
        case imageBackground = "image_background"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.yearEnd = try container.decodeIfPresent(Int.self, forKey: .yearEnd)
        self.yearStart = try container.decodeIfPresent(Int.self, forKey: .yearStart)
        self.gamesCount = try container.decodeIfPresent(Int.self, forKey: .gamesCount)

        let path = try container.decode(String.self, forKey: .imageBackground)

        imageBackground = URL(string: path)
    }

}

struct Requirements: Codable {
    let minimum: String?
    let recommended: String?
}
