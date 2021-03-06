//
//  SearchViewController.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SearchViewController: baseViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var items: Array<Any>? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                self.tableView.isHidden = false
            }
        }
    }
    var titleInputValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        let nib = UINib.init(nibName: "searchTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "searchCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if items != nil { return }
        
        searchBar.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func search(q: String) {
        activityIndicator.startAnimating()
        
        SearchService.sharedInstance.search(query: q) { [unowned self] result in
            self.items = result.items

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func save() {
        guard let selectedIndex = self.tableView.indexPathForSelectedRow?.row else { return }
        
        do {
            let searchItem = try SearchItem(dictionary: items![selectedIndex] as! [String : Any])

            ConvertService.sharedInstance.stream(id: searchItem.id, title: titleInputValue)
        } catch {}
    }
    
    func openSaveDialog() {
        let alert = UIAlertController(
            title: "Save Audio",
            message: "Please enter a title for your audio",
            preferredStyle: .alert)

        alert.addTextField(configurationHandler: { [unowned self] textField in
            textField.placeholder = "Audio title..."
            
            guard let selectedIndex = self.tableView.indexPathForSelectedRow?.row else { return }
            
            do {
                let searchItem = try SearchItem(dictionary: self.items![selectedIndex] as! [String : Any])
                textField.text = String(htmlEncodedString: searchItem.title)
            } catch {}
        })
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [unowned self] action in
            guard let title = alert.textFields?.first?.text else { return }
            if (title == "") { return }
            
            self.titleInputValue = title
            self.save()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
        titleInputValue = ""
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        guard let q = searchBar.text, q != "" else { return }
        
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
            
            cell.cellTitle.text = String(htmlEncodedString: searchItem.title)
            
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
        let alert = UIAlertController(
            title: "Item Selected",
            message: "Would you like to listen or save this audio?",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Listen", style: .default, handler: { [unowned self] action in
            do {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let previewVC = storyBoard.instantiateViewController(withIdentifier: "preview") as! previewViewController
                let searchItem = try SearchItem(dictionary: self.items![indexPath.row] as! [String : Any])
                previewVC.id = searchItem.id
                
                self.present(previewVC, animated: true)
            } catch {}
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [unowned self] action in
            self.openSaveDialog()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
