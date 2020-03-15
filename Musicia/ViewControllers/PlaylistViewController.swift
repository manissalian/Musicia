//
//  PlaylistViewController.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PlaylistViewController: baseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Music]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        items = CoreDataInterface().getAllMusic()
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)
        
        let music = items![indexPath.row]
        
        cell.textLabel?.text = music.title
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete" , handler: { [unowned self](action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            CoreDataInterface().deleteMusic(music: self.items![indexPath.row])
            
            self.items = CoreDataInterface().getAllMusic()
            
            self.tableView.reloadData()
        })
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyBoard.instantiateViewController(withIdentifier: "player") as! playerViewController
        
        var mainPlaylistItems: [String] = []
        for music in items! {
            mainPlaylistItems.append(music.id!)
        }
        PlaylistManager.sharedInstance.loadPlaylist(items: mainPlaylistItems, activeItemIndex: indexPath.row)
        
        self.present(playerVC, animated: true)
    }
}
