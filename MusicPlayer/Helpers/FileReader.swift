//
//  FileReader.swift
//  MusicPlayer
//
//  Created by Pablo Figueroa Martínez on 28/12/20.
//
// This class will get the MP3 files located in the
// documents folder.
//

import UIKit

class FileReader: NSObject {

    class func readFiles() -> [String] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(documentsPath.path)
        let files = try! FileManager.default.contentsOfDirectory(atPath: documentsPath.path)
        var tracks: [String] = []
        
        files.forEach { (string) in
            if string.hasSuffix(".mp3") {
                tracks.append(documentsPath.path + "/" + string)
            }
        }
        
        return tracks
    }
    
}
