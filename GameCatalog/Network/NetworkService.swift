//
//  NetworkService.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 11/12/24.
//

import UIKit

class NetworkService {
    func getGames() async throws -> [Game] {
        var components = URLComponents(string: "https://api.rawg.io/api/games")!
        components.queryItems = [
            URLQueryItem(name: "key", value: try getAPISecretKey())
        ]
        let request = URLRequest(url: components.url!)
        let(data, response) = try await URLSession.shared.data(for: request)
        guard let HTTPresponse = response as? HTTPURLResponse, HTTPresponse.statusCode == 200 else {
            print(response)
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(Games.self, from: data)
            return result.results.map { gameData in
                Game(
                    id: gameData.id,
                    name: gameData.name,
                    released: gameData.released!,
                    rating: gameData.rating,
                    platforms: gameData.platforms,
                    backgroundImage: gameData.backgroundImage!, state: .new,
                    isFavorite: false
                )
            }
        } catch {
            print("Decoding Error: \(error)")
            throw error
        }
    }
}
extension NetworkService {
    enum NetworkServiceError: Error {
        case missingAPIKey
    }

    private func getAPISecretKey() throws -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            throw NetworkServiceError.missingAPIKey
        }
        return key
    }
}
extension NetworkService {
    fileprivate func gameMapper(input gamesData: [GamesData]) -> [Game] {
        return gamesData.map { gamesData in
            _ = gamesData.platforms.map { platform in
                            return platform.requirementsEn != nil ? "Platform with requirements" : "Platform without requirements"
                        }
            return Game(id: gamesData.id,
                        name: gamesData.name,
                        released: gamesData.released!,
                        rating: gamesData.rating,
                        platforms: gamesData.platforms,
                        backgroundImage: gamesData.backgroundImage!, state: .new, isFavorite: false)
        }
    }
}

extension DateFormatter {
    static let gameReleaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
