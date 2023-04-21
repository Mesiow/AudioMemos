//
//  AudioRecorder.swift
//  AudioMemos
//
//  Created by Mesiow on 4/18/23.
//

import Foundation
import UIKit
import AVFoundation

protocol AudioRecorderDelegate {
    func handleAudioRecordingStopped(_ audioMemo : AudioMemo);
}

class AudioRecorder {
    var session : AVAudioSession!
    var recorder : AVAudioRecorder!
    var enabled : Bool = false;
    var recordings : Int = 0;
    
    var delegate : AudioRecorderDelegate?
    var filename : String!
    var soundFileUrl : URL!
    
    func setup() -> Void {
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
                filename  = "New Recording \(recordings)";
                soundFileUrl = getDirectory().appending(path: filename + ".m4a");
                
                let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey : 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue];
                
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
                
                let memo = AudioMemo(title: filename, url: soundFileUrl, date: Date(), length: 0);
                delegate?.handleAudioRecordingStopped(memo);
            }
        }
    }

    
    private func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        let dir = paths[0];
        
        return dir;
    }
}
