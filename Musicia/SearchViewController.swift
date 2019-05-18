//
//  SearchViewController.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConverterService.sharedInstance.search(query: "asot") { result in
            do {
                let searchItem = try SearchItem(dictionary: result.items[0] as! [String : Any])
                print(searchItem)

            } catch {}
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
