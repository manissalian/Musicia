//
//  searchTableViewCell.swift
//  Musicia
//
//  Created by Apple on 5/31/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class searchTableViewCell: UITableViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.image = nil
        cellTitle.text = nil
        cellDuration.text = nil
    }
}
