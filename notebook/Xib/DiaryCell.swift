//
//  DiaryCell.swift
//  notebook
//
//  Created by Rohit Saini on 21/10/20.
//

import UIKit

class DiaryCell: UITableViewCell {

    @IBOutlet weak var diaryTitleLbl: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var timeAgoLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
