//
//  InterfaceController.swift
//  MusicPlayerWatch Extension
//
//  Created by Pablo Figueroa Martínez on 30/12/20.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    var watchSession: WCSession?
    
    @IBOutlet weak var songImage: WKInterfaceImage!
    @IBOutlet weak var songName: WKInterfaceLabel!
    @IBOutlet weak var songArtist: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func previousSong() {
        do {
            try watchSession?.updateApplicationContext(["previous": "Play previous"])
        } catch {
            print(error)
        }
    }
    
    @IBAction func nextSong() {
        do {
            try watchSession?.updateApplicationContext(["next": "Play next"])
        } catch {
            print(error)
        }
    }
    
    @IBAction func play() {
        do {
            try watchSession?.updateApplicationContext(["play": "Play"])
        } catch {
            print(error)
        }
    }
    
    @IBAction func pause() {
        do {
            try watchSession?.updateApplicationContext(["pause": "Pause"])
        } catch {
            print(error)
        }
    }
    
}

extension InterfaceController: WCSessionDelegate {
   
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        print(error ?? "No error detected")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        songImage.setImage(UIImage(data: (applicationContext["track_artwork"] as! Data)))
        songName.setText(applicationContext["track_name"] as? String ?? "Unknown song name")
        songArtist.setText(applicationContext["track_artist"] as? String ?? "Unknown song artist")
    }
}
