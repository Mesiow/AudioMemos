//
//  AudioCell.swift
//  AudioMemos
//
//  Created by Mesiow on 4/16/23.
//

import UIKit

class AudioCell: UITableViewCell {
    var audioCellTitleEdited : ((_ title : String, _ tag : Int) -> Void)!
    var audioCellButtonPressed : ((_ play : Bool) -> Void)!
    
    var expanded : Bool = false;
    var originalCellHeight : CGFloat = 48.0;
    var expandedCellHeight : CGFloat = 115.0
    var audioEnabled : Bool = false;

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var length: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.delegate = self;
        
        // Prevent cell highlighting while preserving selectability and separator views
        var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
        backgroundConfig.backgroundColor = .clear
        backgroundConfiguration = backgroundConfig
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
    }
    
    func enableInteraction(interaction : Bool){
        if interaction {
            title.isUserInteractionEnabled = true;
        }else{
            title.isUserInteractionEnabled = false;
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        audioEnabled.toggle();
        if audioEnabled {
            button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioCellButtonPressed(true);
        }else{
            button.setImage(UIImage(systemName: "play.fill"), for: .normal)
            audioCellButtonPressed(false);
        }
    }
    
    func audioPlaybackStopped(){
        audioEnabled = false;
        button.setImage(UIImage(systemName: "play.fill"), for: .normal);
    }
    
}

extension AudioCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        audioCellTitleEdited(textField.text!, textField.tag);
            
        return true;
    }
}
