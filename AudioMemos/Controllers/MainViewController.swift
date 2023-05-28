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

struct UserDefaultsKey {
    static var recordings = "RecordingsCount"
}

class MainViewController: UIViewController, AudioRPDelegate {
    
    var audiorp : AudioRP!
    var memos : [AudioMemo] = [];
    var selected : [Bool] = []; //cells selected when editing
    
    @IBOutlet weak var buttonBorder: UIButton!
    @IBOutlet weak var innerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var expandedRowIndex : Int = 0;
    var expandRow : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAudioMemos();
        //populate selected boolean array
        for _ in 0..<memos.count {
            selected.append(false)
        }
        
       
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true);
        
        let count = tableView.numberOfRows(inSection: 0);
        if editing {
            navigationItem.leftBarButtonItem?.isHidden = false;
            navigationItem.leftBarButtonItem?.isEnabled = false;
            //disable interaction with the rest of the cell (modyfing memo name etc)
            for i in 0..<count {
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! AudioCell;
                cell.enableInteraction(interaction: false);
            }
            
        }else{
            navigationItem.leftBarButtonItem?.isHidden = true;
            //enable interaction
            for i in 0..<count {
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! AudioCell;
                cell.enableInteraction(interaction: true);
            }
        }
        
        tableView.allowsMultipleSelectionDuringEditing = true;
        tableView.setEditing(editing, animated: true);
    }
    
    private func leaveEditingMode(){
        setEditing(false, animated: true);
        navigationItem.rightBarButtonItem?.isEnabled = false;
        navigationItem.leftBarButtonItem?.isEnabled = false;
    }
    
    private func enableEditingModeAllowed(_ enabled : Bool){
        navigationItem.rightBarButtonItem?.isEnabled = enabled;
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        audiorp.record();
    }
    
    @objc func deleteButtonPressed(_ sender : UIBarButtonItem) {
        sender.isEnabled = false;
        
        deleteSelectedCells();
        
        //return out of editing mode
        if memos.count <= 0 {
            leaveEditingMode();
            
            UserDefaults.standard.set(0, forKey: UserDefaultsKey.recordings);
            audiorp.recordings = UserDefaults.standard.integer(forKey: UserDefaultsKey.recordings);
        }else{
            enableEditingModeAllowed(true);
        }
    }
    
    func deleteSelectedCells(){
        //grab index path values of selected items to delete
        var indexPaths : [IndexPath] = [];
        for i in 0..<selected.count {
            if selected[i] {
                let ip = IndexPath(row: i, section: 0);
                indexPaths.append(ip);
            }
        }
        
        //Remove from core data first
        for i in 0..<indexPaths.count {
            deleteAudioMemoFromCollection(at: indexPaths[i])
        }
        
        //Remove from data source
        //remove from largest index to smallest to avoid array out of index error
        for i in indexPaths.sorted(by: >) {
            let idx = i.row;
            selected.remove(at: idx);
            memos.remove(at: idx);
        }
        
        //begin deleting selected cells
        tableView.beginUpdates();
        tableView.deleteRows(at: indexPaths, with: .left);
        tableView.endUpdates();
        
        reloadAudioMemos();
    }
    
    func handleAudioRecordingStopped(_ memo : AudioMemo) {
        //handle what we want to do once the recording has been stopped
        
        //1. save to core data
        saveAudioMemos();

        //1. add recording to our tableview
        memos.append(memo);
        selected.append(false);
        
        enableEditingModeAllowed(true);
    
        tableView.reloadData();
    }
    
    func handleAudioPlaybackEnded() {
        //recording that we played back ended
        let cell = tableView.cellForRow(at: IndexPath(row: expandedRowIndex, section: 0)) as? AudioCell;
        cell?.audioPlaybackStopped();
    }
    
    private func setupUI(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonPressed));
        navigationItem.leftBarButtonItem?.tintColor = UIColor.systemRed;
        navigationItem.leftBarButtonItem?.isHidden = true;
        
        navigationItem.rightBarButtonItem = editButtonItem;
        if memos.count > 0 {
            enableEditingModeAllowed(true);
        }else{
            enableEditingModeAllowed(false);
        }
        
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
        
        cell.title.text = memos[indexPath.row].filename;
        cell.title.tag = indexPath.row;
        //callback to update audio memo title text
        cell.audioCellTitleEdited = audioCellTitleEdited;
        cell.audioCellButtonPressed = audioCellButtonPressed;
        
        cell.date.text = memos[indexPath.row].date?.formatted(date: .abbreviated, time: .omitted);
        cell.length.text = memos[indexPath.row].length;
        
        return cell;
    }
        
    func audioCellTitleEdited(_ title : String, _ tag : Int) -> Void {
        audiorp.renameAudioMemo(oldName: memos[tag].filename!, newName: title);
        
        memos[tag].filename = title;
        reloadAudioMemos();
    }
    
    func audioCellButtonPressed(_ play : Bool) {
        if play {
            audiorp.playback(memos[expandedRowIndex]);
        }else{
            //pause
            audiorp.pause();
        }
    }
    
    func handleAudioCellSelected(idx : Int){
        if selected.contains(true) {
            //enable nav delete button
            navigationItem.leftBarButtonItem?.isEnabled = true;
            
        }else{
            navigationItem.leftBarButtonItem?.isEnabled = false;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selected[indexPath.row] = true;
            handleAudioCellSelected(idx: indexPath.row)
        } else {
            expandRow = true;
            expandedRowIndex = indexPath.row;
                
            tableView.beginUpdates();
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic);
            tableView.endUpdates();
        }
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.isEditing {
            selected[indexPath.row] = false;
            handleAudioCellSelected(idx: indexPath.row);
        }
        
        return indexPath;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if let cell = tableView.cellForRow(at: indexPath) as? AudioCell {
            if (indexPath.row == expandedRowIndex) && expandRow {
                return cell.expandedCellHeight;
            }else{
                cell.length.isHidden = false;
                return cell.originalCellHeight;
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

