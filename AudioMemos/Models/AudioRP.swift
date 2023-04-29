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
    var recorder : AVAudioRecorder!
    var player : AVAudioPlayer!
    var enabled : Bool = false;
    var recordings : Int = 0;
    
    var delegate : AudioRPDelegate?
    var filename : String!
    var soundFileUrl : URL!
    
    func setup() -> Void {
        //load number of current recordings
        recordings = UserDefaults.standard.integer(forKey: "RecordingsCount");
        
        session = AVAudioSession.sharedInstance();
        do {
            try session.setCategory(.playAndRecord, mode: .default);
            try session.setActive(true);
            session.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.enabled = true;
                        print("mic allowed");
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
        if enabled {
            if recorder == nil { //are we ok to start another recording?
                recordings += 1;
                UserDefaults.standard.set(recordings, forKey: "RecordingsCount");
                
                filename  = "New Recording \(recordings)"; //save recordings count in user defaults
                soundFileUrl = getDirectory().appending(path: filename + ".m4a");
                
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
                print("recording stopped");
                recorder.stop();
                recorder = nil;
                
                let memo = AudioMemo(context: CoreDataContext.context)
                memo.name = filename;
                memo.url = soundFileUrl;
                memo.date = Date();
                memo.length = 0;

                delegate?.handleAudioRecordingStopped(memo);
            }
        }
    }
    
    func playback(_ memo : AudioMemo) {
        if recorder == nil { //not currently recording
            do{
                player = try AVAudioPlayer(contentsOf: memo.url!);
                player.prepareToPlay();
                player.play();
            }catch{
                print("Audio playback error: \(error)");
            }
        }
    }

    
    private func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        let dir = paths[0];
        
        return dir;
    }
}
