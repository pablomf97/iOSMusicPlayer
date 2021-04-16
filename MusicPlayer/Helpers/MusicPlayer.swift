//
//  MusicPlayer.swift
//  MusicPlayer
//
//  Created by Pablo Figueroa Martínez on 28/12/20.
//
// This class consists in a series of methods that will help
// to play music on the device. We will explain func by func.
//

import UIKit
import AVFoundation

// MARK: - Attributes
// The audio player
var player: AVAudioPlayer!
// Index to know which track to play
var currentTrackIndex = 0
// Path to the tracks
var tracks: [String] = [String]()

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    
    // MARK: - Init
    /**
     Initialise the player:
        - Look for the tracks
        - Queue the first track
     */
    override init(){
        tracks = FileReader.readFiles()
        super.init()
        queueTrack();
    }
    
    // MARK: - Queue next track
    func queueTrack() {
        if (player != nil) {
            player = nil
        }
        
        // Converting the paths to URLs
        var url: URL?
        if !tracks.isEmpty {
            url = NSURL.fileURL(withPath: tracks[currentTrackIndex])
        }
        
        do {
            // Setting up the player
            player = try AVAudioPlayer(contentsOf: url ?? URL(fileURLWithPath: ""))
            player?.delegate = self
            player?.prepareToPlay()
            // This will post a internal notification to the system
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackNameText"), object: nil)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Play track
    func play() {
        if player?.isPlaying == false {
            player?.play()
        }
    }
    
    // MARK: - Stop player
    func stop(){
        if player?.isPlaying == true {
            player?.stop()
            player?.currentTime = 0
        }
    }
    
    // MARK: - Pause track
    func pause(){
        if player?.isPlaying == true{
            player?.pause()
        }
    }
    
    // MARK: - Play next track
    func nextSong(songFinishedPlaying:Bool){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
     
        currentTrackIndex += 1
         if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }
        
        queueTrack()
        if playerWasPlaying || songFinishedPlaying {
            player?.play()
        }
    }
    
    // MARK: - Play previous track
    func previousSong(){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        
        currentTrackIndex -= 1
        if currentTrackIndex < 0 {
            currentTrackIndex = tracks.count - 1
        }
             
        queueTrack()
        if playerWasPlaying {
            player?.play()
        }
    }
    
    // MARK: - Get current track name
    func getCurrentTrackName() -> String? {
        var trackName: String?
        
        if !tracks.isEmpty {
            trackName = ((tracks[currentTrackIndex] as NSString).lastPathComponent as NSString).deletingPathExtension
        }
        
        return trackName
    }
    
    // MARK: - Get specific track name
    func getTrackName(index: Int) -> String {
        return ((tracks[index] as NSString).lastPathComponent as NSString).deletingPathExtension
    }
    
    // MARK: - Get currently playing mp3 metadata
    func getCurrentMP3Metadata() -> [Any?] {
        var title: String?
        var artist: String?
        var image: UIImage?
        
        if !tracks.isEmpty {
            let playerItem = AVPlayerItem(url: NSURL.fileURL(withPath: tracks[currentTrackIndex]))
            let metadata = playerItem.asset.metadata
            
            for item in metadata {
                guard let key = item.commonKey?.rawValue, let value = item.value else {
                        continue
                }
                
                switch key {
                    case "title": title = value as? String ?? nil
                    case "artist": artist = value as? String ?? nil
                    case "artwork" where value is Data : image = UIImage(data: value as! Data) ?? nil
                    default:
                        continue
                    }
            }
        }
        return [title, artist, image]
    }
    
    // MARK: - Get specified mp3 metadata
    func getMP3Metadata(track: String) -> [Any?] {
        var title: String?
        var artist: String?
        var image: UIImage?
        
        let playerItem = AVPlayerItem(url: NSURL.fileURL(withPath: track))
        let metadata = playerItem.asset.metadata
        
        for item in metadata {
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                    continue
            }
            
            switch key {
            case "title": title = value as? String ?? nil
            case "artist": artist = value as? String ?? nil
            case "artwork" where value is Data : image = UIImage(data: value as! Data) ?? nil
            default:
                continue
            }
        }
        return [title, artist, image]
    }
    
    // MARK: - Get total track time
    func getTrackDuration() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.duration {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
    
    // MARK: - Get current track time
    func getCurrentTimeAsString() -> String {
       var seconds = 0
       var minutes = 0
       if let time = player?.currentTime {
           seconds = Int(time) % 60
           minutes = (Int(time) / 60) % 60
       }
       return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
    
    // MARK: - Get current track progress
    func getProgress()->Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        if let currentTime = player?.currentTime, let duration = player?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }
    
    // MARK: - Set player volume
    func setVolume(volume:Float){
        player?.volume = volume
    }
    
    // MARK: - Check is some track is playing
    func isPlaying() -> Bool {
        return player?.isPlaying == true
    }
    
    // MARK: - Delegate stuff
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            nextSong(songFinishedPlaying: true)
            }
    }
}
