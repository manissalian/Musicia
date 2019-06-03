//
//  PlaylistViewController.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreData

class PlaylistViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "playlistCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchItems()
        
        tableView.reloadData()
    }
    
    func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Music")
        
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func deleteItem(item: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(item)
        
        do {
            try managedContext.save()
            
            fetchItems()
            
            tableView.reloadData()
        } catch {}
    }
}

// MARK: - UITableViewDataSource
extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.value(forKeyPath: "title") as? String
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.deleteItem(item: self.items[indexPath.row])
        })
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyBoard.instantiateViewController(withIdentifier: "player")
        
        self.present(playerVC, animated: true) {
        }
    }
}
