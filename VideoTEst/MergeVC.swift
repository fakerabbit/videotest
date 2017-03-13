//
//  MergeVC.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import MobileCoreServices
import AVKit
import Photos

class MergeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
    lazy var customView:MergeView! = {
        let frame = UIScreen.main.bounds
        let v = MergeView(frame: frame)
        return v
    }()
    
    // MARK:- View methods
    
    override func loadView() {
        super.loadView()
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Merge"
        self.customView.loadOne.addTarget(self, action: #selector(onLoadOne(_:)), for: .touchUpInside)
        self.customView.loadTwo.addTarget(self, action: #selector(onLoadTwo(_:)), for: .touchUpInside)
        self.customView.mergeSave.addTarget(self, action: #selector(onMerge(_:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Handlers
    
    func savedPhotosAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func startMediaBrowserFromViewController(viewController: UIViewController!) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = self
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
            }, completionHandler: { success, error in
                
                var title = ""
                var message = ""
                if error != nil {
                    title = "Error"
                    message = "Failed to save video"
                } else {
                    title = "Success"
                    message = "Video saved"
                }
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
        
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
    }
    
    func onLoadOne(_ sender: UIButton) {
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(viewController: self)
        }
    }
    
    func onLoadTwo(_ sender: UIButton) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(viewController: self)
        }
    }
    
    func onMerge(_ sender: UIButton) {
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        let mutableCompositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // 2 - Video track
        let videoAssetTrack: AVAssetTrack = (self.firstAsset?.tracks(withMediaType: AVMediaTypeVideo).first!)!
        
        let secondAssetTrack: AVAssetTrack = (self.secondAsset?.tracks(withMediaType: AVMediaTypeVideo).first!)!
        
        try! mutableCompositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
        
        try! mutableCompositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAssetTrack.timeRange.duration), of: secondAssetTrack, at:videoAssetTrack.timeRange.duration)
        
        // 3 - Get path
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = NSURL(fileURLWithPath: savePath)
        
        // 4 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url as URL
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        
        // 5 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async() { _ in
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    // MARK:- Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = AVAsset(url:(info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
            var message = ""
            if loadingAssetOne {
                message = "Video one loaded"
                firstAsset = avAsset
            } else {
                message = "Video two loaded"
                secondAsset = avAsset
            }
            let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
}

