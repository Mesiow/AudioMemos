//
//  AudioRecorder.swift
//  AudioMemos
//
//  Created by Mesiow on 4/18/23.
//

import Foundation
import UIKit
import AVFoundation

protocol AudioRPDelegate {
    func handleAudioRecordingStopped(_ audioMemo : AudioMemo);
}

//implementation for audio recording and playback
class AudioRP {
    var session : AVAudioSession!
    var recorder : AVAudioRecorder! = nil
    var player : AVAudioPlayer!
    var enabled : Bool = false;
    var recordings : Int = 0;
    
    var delegate : AudioRPDelegate?
    var filename : String!
    let ext : String = ".m4a";
    
    var start : TimeInterval!
    var finish : TimeInterval!
    
    func setup() -> Void {
        //load number of current recordings
        recordings = UserDefaults.standard.integer(forKey: "RecordingsCount");
        
        session = AVAudioSession.sharedInstance();
        do {
            try session.setCategory(.record, mode: .default);
            try session.setActive(true);
            session.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.enabled = true;
                        print("Mic allowed");
                    }else{
                        self.enabled = false;
                        print("--Error failed asking for permission to record audio--")
                    }
                }
            }
        }catch{
            print("--Error failed to setup audio recording session: \(error)--");
        }
    }
    
    func record() -> Void {
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true);
        }catch{
            print("--Error failed when setting session category for recording--");
            return;
        }
        
        if enabled {
            if recorder == nil { //are we ok to start another recording?
                start = Date().timeIntervalSince1970;
                
                recordings += 1;
                
                filename = "New Recording \(recordings)"; //save recordings count in user defaults
                let soundFileUrl = getDirectory().appending(path: filename + ext);
                
                let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey : 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue];
                
                //start recording
                do {
                    recorder = try AVAudioRecorder(url: soundFileUrl, settings: settings);
                    recorder.record();
                    print("recording");
                }catch{
                    print("Failed to start recording: \(error)")
                }
            }
            else{
                UserDefaults.standard.set(recordings, forKey: "RecordingsCount");
                
                recorder.stop();
                recorder = nil;
                
                finish = Date().timeIntervalSince1970;
                let diff = Int32(finish - start);
                let time = secondsToMinSec(seconds: diff);
                
                let memo = AudioMemo(context: CoreDataContext.context)
                memo.filename = filename;
                memo.date = Date();
                memo.length = "\(time.min):\(String(format: "%02d", time.sec))";

                delegate?.handleAudioRecordingStopped(memo);
            }
        }
    }
    
    func playback(_ memo : AudioMemo) {
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true);
        }catch{
            print("--Error failed when setting session category for playback--");
            return;
        }
        
        if recorder == nil { //not currently recording
            do{
                let url = getDirectory().appending(path: memo.filename! + ext);
                
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: ext);
                player.prepareToPlay();
                player.play();
            }catch let error as NSError{
                print("Audio playback error: \(error.description)");
            }
        }
    }
    
    func renameAudioMemo(_ memo : AudioMemo) {
        
    }

    
    private func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        let dir = paths[0];
        
        return dir;
    }
    
    private func secondsToMinSec(seconds : Int32) -> (min: Int32, sec: Int32) {
        return (((seconds % 3600) / 60), ((seconds % 3600) % 60));
    }
}
