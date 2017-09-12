//
//  TableViewCell.swift
//  ImageToPhoto
//
//  Created by Sumedh Ravi on 11/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {


    @IBOutlet weak var songName: UILabel!
    
  
    @IBOutlet weak var durationLabel: UILabel!

    var isPlaying : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        self.songName.textColor = UIColor.white
        self.songName.textColor = UIColor.white
        //selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
