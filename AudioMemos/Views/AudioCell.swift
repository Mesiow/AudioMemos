//
//  AudioCell.swift
//  AudioMemos
//
//  Created by Mesiow on 4/16/23.
//

import UIKit

class AudioCell: UITableViewCell {
    var audioCellTitleEdited : ((_ title : String, _ tag : Int) -> Void)!
    
    var expanded : Bool = false;
    var originalCellHeight : CGFloat = 48.0;
    var expandedCellHeight : CGFloat = 144.0

    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var length: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.delegate = self;
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

extension AudioCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        audioCellTitleEdited(textField.text!, textField.tag);
            
        return true;
    }
}
