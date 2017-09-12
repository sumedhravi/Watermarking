//
//  CollectionViewCell.swift
//  ImageCollection
//
//  Created by Sumedh Ravi on 07/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet var cellImage: UIImageView!
    
    @IBOutlet var selectionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
