//
//  SearchViewController.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Array<Any>? {
        didSet {
            DispatchQueue.main.async{
                self.tableView.reloadData()
                
                self.tableView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        let nib = UINib.init(nibName: "searchTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "searchCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if items != nil { return }
        
        searchBar.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func search(q: String) {
        ConverterService.sharedInstance.search(query: q) { result in
            self.items = result.items
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        guard let q = searchBar.text else { return }
        
        search(q: q)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchTableViewCell
        
        do {
            let searchItem = try SearchItem(dictionary: items![indexPath.row] as! [String : Any])
            
            cell.cellTitle.text = searchItem.title
            
            cell.cellDuration.text = secondsToTime(seconds: searchItem.duration)
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let image = UIImage(data: try Data(contentsOf: URL(string: searchItem.thumbnailUrl)!))
                    
                    DispatchQueue.main.async {
                        cell.cellImageView.image = image
                    }
                } catch {}
            }
        } catch {}
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            let searchItem = try SearchItem(dictionary: items![indexPath.row] as! [String : Any])
            
            ConverterService.sharedInstance.convert(id: searchItem.id) { result in
                ConverterService.sharedInstance.download(id: result) { data in
                    print("downloaded data!")
                }
            }
        } catch {}
    }
}
