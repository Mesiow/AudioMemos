//
//  ViewController.swift
//  AudioMemos
//
//  Created by Mesiow on 4/15/23.
//

import UIKit
import CoreData

struct Constants {
    static var cellIdentifier = "ReusableAudioCell";
    static var cellNibName = "AudioCell"
}

class MainViewController: UIViewController, AudioRPDelegate {
    
    var audiorp : AudioRP!
    var memos : [AudioMemo] = [];
    
    @IBOutlet weak var buttonBorder: UIButton!
    @IBOutlet weak var innerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var expandedRowIndex : Int = 0;
    var expandRow : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*deleteAllRecords();
        UserDefaults.standard.removeObject(forKey: "RecordingsCount");*/
        
        loadAudioMemos();
        
        audiorp = AudioRP();
        audiorp.delegate = self;
        audiorp.setup();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier);
        
        searchBar.delegate = self;
        searchBar.backgroundImage = UIImage();
        
        setupUI();
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        audiorp.record();
    }
    
    func handleAudioRecordingStopped(_ memo : AudioMemo) {
        //handle what we want to do once the recording has been stopped
        
        //1. save to core data
        saveAudioMemos();

        //1. add recording to our tableview
        memos.append(memo);
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
        return memos.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! AudioCell
        
        cell.title.text = memos[indexPath.row].name;
        cell.date.text = memos[indexPath.row].date?.formatted(date: .abbreviated, time: .omitted);
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
        
        audiorp.playback(memos[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      /* if let cell = tableView.cellForRow(at: indexPath) as? AudioCell {
            if indexPath.row == expandedRowIndex && expandRow {
                cell.length.isHidden = true;
                return cell.expandedCellHeight;
            }else{
                cell.length.isHidden = false;
                return cell.originalCellHeight;
            }
        }*/
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
        
        searchBar.text = "";
        loadAudioMemos();
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            if text.count == 0 {
                loadAudioMemos();
                DispatchQueue.main.async {
                    searchBar.setShowsCancelButton(false, animated: true);
                    searchBar.resignFirstResponder(); //dismiss keyboard
                }
            }else{
                liveUpdateSearch();
            }
        }
    }
    
    func liveUpdateSearch(){
        //create a request
        let req : NSFetchRequest<AudioMemo> = AudioMemo.fetchRequest();
        //filter for name of audio memo
        let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!);
        
        req.predicate = namePredicate;
        
        //How to store results
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true);
        req.sortDescriptors = [sortDescriptor];
        
        loadAudioMemos(with: req);
    }
}

