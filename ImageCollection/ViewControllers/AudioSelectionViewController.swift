//
//  AudioSelectionViewController.swift
//  ImageToPhoto
//
//  Created by Sumedh Ravi on 11/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation

class AudioSelectionViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var audioList = ["Track 0", "Track 1", "Track 2", "Track 3", "Track 4", "Track 5", "Track 6"]
    var selectedVideo = NSURL(fileURLWithPath:"")
    var audioPlayer = AVAudioPlayer()
    var selectedAudio = NSURL(fileURLWithPath: "")
    
    @IBOutlet weak var songList: UITableView!
    
    override func viewDidDisappear(_ animated: Bool) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songList.delegate = self
        songList.dataSource = self
        self.songList.register(UINib(nibName: "TableViewCell", bundle: nil) , forCellReuseIdentifier: "tableCell")
        songList.allowsMultipleSelection = false
        songList.backgroundColor = UIColor.black

        let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector (proceed))
        self.navigationItem.rightBarButtonItem = newBackButton

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = songList.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        cell.songName.text = audioList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackID = indexPath.row
        let path: String! = Bundle.main.resourcePath?.appending("/\(trackID).mp3")
        let mp3URL = NSURL(fileURLWithPath: path)
        selectedAudio = mp3URL
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        if(cell.isPlaying){
            audioPlayer.pause()
            cell.isPlaying = false
        }
        else{
            
        do
        {
//            if() {
//                audioPlayer.pause()
//            }
//            else{
            audioPlayer = try AVAudioPlayer(contentsOf: mp3URL as URL)
            audioPlayer.play()
            cell.isPlaying = true
            cell.accessoryType = .checkmark
            cell.durationLabel.text = "Duration: \(audioPlayer.duration)"
            
        }
        catch
        {
            print("An error occurred while trying to extract audio file")
            }}
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        audioPlayer.stop()
        
        let cell = songList.cellForRow(at: indexPath) as! TableViewCell
        cell.accessoryType = .none
        cell.durationLabel.text = ""
    }
    
    func proceed(){
        
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "compositeVC") as! CompositeVideoViewController
        newController.videoFileURL = selectedVideo
        newController.audioFileURL = selectedAudio
        navigationController?.pushViewController(newController, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
