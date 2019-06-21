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
    func getAllMusic() -> [Music]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Music")
        
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
