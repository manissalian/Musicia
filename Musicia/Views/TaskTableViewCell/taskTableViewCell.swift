//
//  taskTableViewCell.swift
//  Musicia
//
//  Created by Apple on 6/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class taskTableViewCell: UITableViewCell {
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        titleLabel.text = nil
        progressLabel.text = nil
    }
}
