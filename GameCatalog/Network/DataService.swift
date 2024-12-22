//
//  DataService.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 17/12/24.
//

import UIKit
import CoreData

class DataService {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameModel")
        do {
            try loadPersistentStores(for: container)
        } catch {
            print("Failed to load persistent stores: \(error)")
        }
        return container
    }()
    
    private func loadPersistentStores(for container: NSPersistentContainer) throws {
        var loadError: Error?
        container.loadPersistentStores { _, error in
            if let error = error {
                loadError = error
            }
        }
        if let loadError = loadError {
            throw loadError
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    func saveFavorite(_ game: Game, completion: @escaping (Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteGame")
            fetchRequest.predicate = NSPredicate(format: "id == \(game.id)")
            do {
                let existingGames = try taskContext.fetch(fetchRequest)
                if let existingGame = existingGames.first {
                    self.updateFavoriteGame(existingGame, game: game, context: taskContext, completion: completion)
                } else {
                    self.insertNewFavoriteGame(game, context: taskContext, completion: completion)
                }
            } catch {
                print("Failed to fetch favorite for update: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    private func insertNewFavoriteGame(_ game: Game, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        let favoriteGame = NSEntityDescription.insertNewObject(forEntityName: "FavoriteGame", into: context)
        favoriteGame.setValue(game.id, forKey: "id")
        favoriteGame.setValue(game.name, forKey: "name")
        favoriteGame.setValue(game.released, forKey: "released")
        favoriteGame.setValue(game.rating, forKey: "rating")
        favoriteGame.setValue(game.backgroundImage?.absoluteString, forKey: "backgroundImage")
        favoriteGame.setValue(game.state == .downloaded ? "downloaded" : "new", forKey: "state")
        favoriteGame.setValue(game.isFavorite, forKey: "isFavorite")
        do {
            let platformsData = try JSONEncoder().encode(game.platforms)
            if let platformsJSONString = String(data: platformsData, encoding: .utf8) {
                favoriteGame.setValue(platformsJSONString, forKey: "platforms")
            }
            try context.save()
            completion(true)
        } catch {
            print("Failed to save new favorite game: \(error.localizedDescription)")
            completion(false)
        }
    }

    private func updateFavoriteGame(_ existingGame: NSManagedObject, game: Game, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        existingGame.setValue(game.name, forKey: "name")
        existingGame.setValue(game.released, forKey: "released")
        existingGame.setValue(game.rating, forKey: "rating")
        existingGame.setValue(game.backgroundImage?.absoluteString, forKey: "backgroundImage")
        existingGame.setValue(game.state == .downloaded ? "downloaded" : "new", forKey: "state")
        existingGame.setValue(game.isFavorite, forKey: "isFavorite")
        do {
            let platformsData = try JSONEncoder().encode(game.platforms)
            if let platformsJSONString = String(data: platformsData, encoding: .utf8) {
                existingGame.setValue(platformsJSONString, forKey: "platforms")
            }
            try context.save()
            completion(true)
        } catch {
            print("Failed to update favorite game: \(error.localizedDescription)")
            completion(false)
        }
    }

    func loadAllFavorites(completion: @escaping ([Game]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteGame")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [Game] = []
                for result in results {
                    var platforms: [PlatformData] = []
                    if let platformsJSON = result.value(forKey: "platforms") as? String,
                       let jsonData = platformsJSON.data(using: .utf8) {
                        platforms = try JSONDecoder().decode([PlatformData].self, from: jsonData)
                    }
                    let game = Game(
                        id: result.value(forKey: "id") as? Int32 ?? 0,
                        name: result.value(forKey: "name") as? String ?? "",
                        released: result.value(forKey: "released") as? Date,
                        rating: result.value(forKey: "rating") as? Double ?? 0.0,
                        platforms: platforms,
                        backgroundImage: URL(string: result.value(forKey: "backgroundImage") as? String ?? ""),
                        state: .new,
                        isFavorite: true
                    )
                    games.append(game)
                }
                completion(games)
            } catch {
                print("Failed to load all favorites: \(error.localizedDescription)")
                completion([])
            }
        }
    }

    func deleteFavorite(_ id: Int32, completion: @escaping (Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteGame")
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try taskContext.execute(batchDeleteRequest)
                completion(true)
            } catch {
                print("Failed to delete favorite: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    func isFavorite(_ id: Int32, completion: @escaping (Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteGame")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            do {
                let results = try taskContext.fetch(fetchRequest)
                completion(!results.isEmpty)
            } catch {
                print("Failed to check favorite status: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
