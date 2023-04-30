//
//  AudioMemoCoreData.swift
//  AudioMemos
//
//  Created by Mesiow on 4/29/23.
//

import Foundation
import CoreData
import UIKit

struct CoreDataContext {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
}

extension MainViewController {
    func saveAudioMemos() {
        do {
            try CoreDataContext.context.save();
        }catch {
            print("(Core data) Error saving memos \(error)");
        }
    }
    
    func loadAudioMemos(with request : NSFetchRequest<AudioMemo> = AudioMemo.fetchRequest()) {
        do{
            memos = try CoreDataContext.context.fetch(request);
        }catch {
            print("(Core data) Error loading memos \(error)");
        }
        tableView.reloadData();
    }
    
    func reloadAudioMemos(){
        saveAudioMemos();
        loadAudioMemos();
        tableView.reloadData();
    }
    
    func deleteAudioMemoFromCollection(at indexPath: IndexPath){
        CoreDataContext.context.delete(memos[indexPath.row]); //implicity saves the changes of deletion to core data
        reloadAudioMemos();
    }
    
    func deleteAllRecords() {
           //delete all data

           let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioMemo")
           let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

           do {
               try CoreDataContext.context.execute(deleteRequest)
               try CoreDataContext.context.save()
           } catch {
               print ("There was an error deleting records")
           }
       }
    
}
