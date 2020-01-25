//
//  coreDataQueries.swift
//  Musicia
//
//  Created by Apple on 6/21/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataInterface {
    private func makeMainPlaylist() {
        // creates a unique playlist with type set to 'main'
        // the playlist is responsible of displaying all the music from the users library
        // only succeeds the first time the app is launched
        // it's the only playlist that has no items array
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchMainRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        let predicate = NSPredicate(format: "type = %@", argumentArray: ["main"])
        fetchMainRequest.predicate = predicate
        do {
            let result = try managedContext.fetch(fetchMainRequest)
            
            if (result.count > 0) { return }
            
            let mainPlaylist = Playlist(context: managedContext)
            mainPlaylist.title = "All Music"
            mainPlaylist.type = "main"
        } catch {}
    }
    
    func getAllPlaylists() -> [Playlist]? {
        makeMainPlaylist()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Playlist")
        
        do {
            let items = try managedContext.fetch(fetchRequest) as? [Playlist]
            
            return items
        } catch {
            return nil
        }
    }
    
    func deletePlaylist(playlist: Playlist) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            playlist.type != "main" else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(playlist)
        
        do {
            try managedContext.save()
        } catch {}
    }
    
    func getAllMusic() -> [Music]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Music")
        fetchRequest.propertiesToFetch = ["id", "title"]
        
        do {
            let items = try managedContext.fetch(fetchRequest) as? [Music]
            
            return items
        } catch {
            return nil
        }
    }
    
    func getMusicById(id: String) -> Music? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Music")
        let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        fetch.predicate = predicate
        
        var music: Music?
        do {
            let result = try managedContext.fetch(fetch)
            
            music = result[0] as? Music
        } catch {}
        
        return music
    }
    
    func saveMusic(id: String, title: String, fileData: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Music", in: managedContext)!
        
        let music = NSManagedObject(entity: entity, insertInto: managedContext) as! Music
        music.id = id
        music.title = title
        music.file = fileData
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func deleteMusic(music: Music) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(music)
        
        do {
            try managedContext.save()
        } catch {}
    }
}
