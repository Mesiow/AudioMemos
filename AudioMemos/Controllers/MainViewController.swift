//
//  ViewController.swift
//  AudioMemos
//
//  Created by Mesiow on 4/15/23.
//

import UIKit

struct Constants {
    static var cellIdentifier = "ReusableAudioCell";
    static var cellNibName = "AudioCell"
}

struct AudioMemo {
    var title : String;
    var url : URL;
    var date : Date;
    var length: Int;
}

class MainViewController: UIViewController, AudioRecorderDelegate {
    
    var audioRecorder : AudioRecorder!
    var audioMemos : [AudioMemo] = [];
    
    @IBOutlet weak var buttonBorder: UIButton!
    @IBOutlet weak var innerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var expandedRowIndex : Int = 0;
    var expandRow : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioRecorder = AudioRecorder();
        audioRecorder.delegate = self;
        audioRecorder.setup();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier);
        
        searchBar.delegate = self;
        searchBar.backgroundImage = UIImage();
        
        setupUI();
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        audioRecorder.record();
    }
    
    func handleAudioRecordingStopped(_ memo : AudioMemo) {
        //handle what we want to do once the recording has been stopped

        //1. add recording to our tableview
        audioMemos.append(memo);
        tableView.reloadData();
    }
    
    private func setupUI(){
        //Button setup
        buttonBorder.frame.size.width = 75.0;
        buttonBorder.frame.size.height = 75.0
        buttonBorder.layer.cornerRadius = 0.5 * buttonBorder.bounds.size.width;
        buttonBorder.clipsToBounds = true;
        buttonBorder.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 255);
        buttonBorder.layer.borderWidth = 4.0
        buttonBorder.tintColor = UIColor.clear
        buttonBorder.isEnabled = false;
        
        innerButton.frame.size.width = 60.0;
        innerButton.frame.size.height = 60.0;
        innerButton.layer.cornerRadius = 0.5 * innerButton.bounds.size.width;
        innerButton.clipsToBounds = true;
        innerButton.tintColor = UIColor.systemRed;
        innerButton.layer.position = buttonBorder.layer.position;
    }
}

//MARK: - Table view functionality
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioMemos.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! AudioCell
        
        cell.title.text = audioMemos[indexPath.row].title;
        cell.date.text = audioMemos[indexPath.row].date.formatted(date: .abbreviated, time: .omitted);
        cell.length.text = "0:00";
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        
        expandRow = true;
        expandedRowIndex = indexPath.row;
    
        tableView.beginUpdates();
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic);
        tableView.endUpdates();
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? AudioCell {
            if indexPath.row == expandedRowIndex && expandRow {
                cell.length.isHidden = true;
                return cell.originalCellHeight * 2.0;
            }else{
                cell.length.isHidden = false;
            }
        }
        return UITableView.automaticDimension;
    }
}


//MARK: - Search bar functionality
extension MainViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true);
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        searchBar.setShowsCancelButton(false, animated: true);
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

