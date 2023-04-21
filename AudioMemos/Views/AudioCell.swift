//
//  AudioCell.swift
//  AudioMemos
//
//  Created by Mesiow on 4/16/23.
//

import UIKit

class AudioCell: UITableViewCell {
    var expanded : Bool = false;
    var originalCellHeight : CGFloat = 48.0;
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var length: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
    }
    
}
