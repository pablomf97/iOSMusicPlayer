//
//  LibraryViewController.swift
//  MusicPlayer
//
//  Created by Pablo Figueroa Martínez on 25/12/20.
//
// Table that contains the tracks on the device
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var songTableView: UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
    }

    // MARK: - Table stuff
    func setupTable() {
        songTableView.delegate = self
        songTableView.dataSource = self
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SongCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
       
        let songData = musicPlayer?.getMP3Metadata(track: tracks[indexPath.row])
        
        cell.songNameLabel!.text = songData?[0] as? String ?? musicPlayer?.getTrackName(index: indexPath.row)
        cell.authorNameLabel!.text = songData?[1] as? String ?? "Artist unkown"
        cell.songImage.image = songData?[2] as? UIImage ?? UIImage(named: "default_music_image")
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.selectedIndex = 0
        let view = tabBarController?.viewControllers![0] as! MusicPlayerViewController
        view.shouldPlay = true
        currentTrackIndex = indexPath.row
    }
    
}
