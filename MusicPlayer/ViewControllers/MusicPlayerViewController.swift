//
//  MusicPlayerViewController.swift
//  MusicPlayer
//
//  Created by Pablo Figueroa Martínez on 25/12/20.
//
// This is the view that controlls the music player
//

import UIKit
import WatchConnectivity

var musicPlayer: MusicPlayer?

class MusicPlayerViewController: UIViewController {
    
    var session : WCSession?

    // MARK: - Attributes
    var timer: Timer?
    var shouldPlay = false
    
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    
    @IBOutlet weak var currentSongSecs: UILabel!
    @IBOutlet weak var totalSongSecs: UILabel!
    @IBOutlet weak var songProgress: UIProgressView!
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    var volume = UserDefaults.standard.float(forKey: "volume")
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Overrided funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicPlayer = MusicPlayer()
        setupNotificationCenter()
        updateViews()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(volumeSlider.value, forKey: "volume")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        volume = UserDefaults.standard.float(forKey: "volume")
        volumeSlider.setValue(volume, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldPlay {
            musicPlayer?.queueTrack()
            musicPlayer?.play()
            play()
            shouldPlay = false
        }
        setTrackData()
    }
    
    // MARK: - Dealing with the music player
    func play() {
        musicPlayer?.play()
        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.circle"), for: .normal)
        startTimer()
    }
    
    func pause() {
        musicPlayer?.pause()
        playPauseButton.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
        timer?.invalidate()
    }
    
    @IBAction func playPreviousSong() {
        musicPlayer?.previousSong()
        setTrackData()
        startTimer()
    }
    
    @IBAction func playPause() {
        if musicPlayer?.isPlaying() == false {
            play()
        } else {
            pause()
        }
    }
    
    @IBAction func playNextSong() {
        musicPlayer?.nextSong(songFinishedPlaying: false)
        setTrackData()
        startTimer()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MusicPlayerViewController.updateViewsWithTimer(theTimer: )), userInfo: nil, repeats: true)
    }
    
    @objc func updateViewsWithTimer(theTimer: Timer){
        updateViews()
    }
    
    func updateViews(){
        currentSongSecs.text = musicPlayer?.getCurrentTimeAsString()
        totalSongSecs.text = musicPlayer?.getTrackDuration()
        
        if let progress = musicPlayer?.getProgress() {
            songProgress.progress = progress
        }
    }
    
    func setTrackData(){
        let songData = musicPlayer?.getCurrentMP3Metadata()
        
        let name = songData?[0] as? String ?? musicPlayer?.getCurrentTrackName() ?? "Song name unknown"
        let artist = songData?[1] as? String ?? "Artist unkown"
        let image = songData?[2] as? UIImage ?? UIImage(named: "default_music_image")!
        
        songName.text = name
        songArtist.text = artist
        musicImage.image = image
        
        sendMessage(songName: name, songArtist: artist, songArtwork: image)
    }
    
    func sendMessage(songName name : String, songArtist artist : String, songArtwork artwork : UIImage) {
        do {
            let imageData = artwork.jpegData(compressionQuality: 0.0)!
            
            let data = ["track_name": name as Any, "track_artist": artist as Any, "track_artwork": imageData as Any]
            try session?.updateApplicationContext(data)
        } catch {
            print(error)
        }
    }
    
    func setupNotificationCenter(){
        NotificationCenter.default.addObserver(self,
            selector: #selector(MusicPlayerViewController.setCurrentTrackData),
            name: NSNotification.Name(rawValue: "SetTrackNameText"),
            object:nil)
    }
    
    @objc func setCurrentTrackData() {
        setTrackData()
    }
    
    @IBAction func setVolume(_ sender: UISlider) {
        musicPlayer?.setVolume(volume: sender.value)
    }

}

// MARK: - WatchKit session delegate
extension MusicPlayerViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        DispatchQueue.main.async {
            if applicationContext["play"] != nil {
                self.play()
            } else if applicationContext["pause"] != nil {
                self.pause()
            } else if applicationContext["next"] != nil {
                self.playNextSong()
            } else if applicationContext["previous"] != nil {
                self.playPreviousSong()
            }
        }
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
}
