//
//  playlistsViewController.swift
//  Musicia
//
//  Created by Apple on 6/22/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PlaylistsViewController: baseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Playlist]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "playlistCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        items = CoreDataInterface().getAllPlaylists()
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PlaylistsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        let playlist = items![indexPath.row]
        
        cell.textLabel?.text = playlist.title
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete" , handler: { [unowned self](action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            CoreDataInterface().deletePlaylist(playlist: self.items![indexPath.row])
            
            self.items = CoreDataInterface().getAllPlaylists()
            
            self.tableView.reloadData()
        })
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyBoard.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
        
        self.navigationController?.pushViewController(playerVC, animated: true)
    }
}
