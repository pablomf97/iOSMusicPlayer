//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Pablo Figueroa Martínez on 28/12/20.
//
// This class contains the cell for the track's list
//

import UIKit

class SongCell: UITableViewCell {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
