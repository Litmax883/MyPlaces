//
//  TableViewCell.swift
//  MyPlaces
//
//  Created by MAC on 28.07.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import Cosmos

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imageInCell: UIImageView! {
        didSet {
        imageInCell.layer.cornerRadius = imageInCell.bounds.height / 2
        imageInCell.clipsToBounds = true
        }

    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
