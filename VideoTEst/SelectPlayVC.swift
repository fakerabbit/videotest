//
//  SelectPlayVC.swift
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

class SelectPlayVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var customView:SelectPlayView! = {
        let frame = UIScreen.main.bounds
        let v = SelectPlayView(frame: frame)
        return v
    }()
    
    var videoAsset: AVAsset?
    var videoURL: URL!
    
    // MARK:- View methods
    
    override func loadView() {
        super.loadView()
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Select Play"
        self.customView.play.addTarget(self, action: #selector(onPlay(_:)), for: .touchUpInside)
        self.customView.mergeSave.addTarget(self, action: #selector(onSave(_:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
    
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    // MARK:- Handlers
    
    func onPlay(_ sender: UIButton) {
        _ = startMediaBrowserFromViewController(viewController: self, usingDelegate: self)
    }
    
    func onSave(_ sender: UIButton) {
        self.createComposition()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true) {
            
            if mediaType == kUTTypeMovie {
                
                let avAsset = AVAsset(url:(info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
                self.videoAsset = avAsset
                self.videoURL = (info[UIImagePickerControllerMediaURL] as! NSURL) as URL
                self.customView.asset = avAsset
                
                //let player:AVPlayer! = AVPlayer(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
                let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
                let player:AVPlayer! = AVPlayer(playerItem: playerItem)
                /*let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: {
                    player.play()
                })*/
                self.customView.playerLayer.player = player
                player.play()
            }
        }
    }
    
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, size: CGSize) {
        
        let pad: CGFloat = 5
        let title = self.customView.textField.text
        let titleLayer = CATextLayer()
        titleLayer.string = title
        titleLayer.frame =  CGRect(x: pad, y: pad, width: size.width - pad * 2, height: size.height - pad * 2)
        let fontName: CFString = "GillSans-UltraBold" as CFString
        let fontSize: CGFloat = 28
        titleLayer.font = CTFontCreateWithName(fontName, fontSize, nil)
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.foregroundColor = UIColor.white.cgColor
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        backgroundLayer.masksToBounds = true
        backgroundLayer.addSublayer(titleLayer)
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(backgroundLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }
    
    func createComposition() {
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        let mutableCompositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // 2 - Video track
        let videoAssetTrack: AVAssetTrack = (self.videoAsset?.tracks(withMediaType: AVMediaTypeVideo).first!)!
        
        try! mutableCompositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
        
        // Composition
        
        var isFirstVideoPortrait = false
        let firstTransform: CGAffineTransform = videoAssetTrack.preferredTransform
        
        if firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0) {
            isFirstVideoPortrait = true
        }
        
        // Instructions
        
        let firstVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
        
        let firstVideoLayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mutableCompositionVideoTrack)
        firstVideoLayerInstruction.setTransform(firstTransform, at: kCMTimeZero)
        firstVideoCompositionInstruction.layerInstructions = [firstVideoLayerInstruction]
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = [firstVideoCompositionInstruction]
        
        // Render size & duration
        
        var naturalSizeFirst = CGSize.zero
        if isFirstVideoPortrait == true {
            naturalSizeFirst = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
        }
        else {
            naturalSizeFirst = videoAssetTrack.naturalSize
        }
        let renderSize = naturalSizeFirst
        //let renderFloat = fminf(Float(naturalSizeFirst.width), Float(naturalSizeFirst.height))
        //let renderSize = CGSize(width: CGFloat(renderFloat), height: CGFloat(renderFloat))
        /*if naturalSizeFirst.height >= naturalSizeFirst.width {
            renderSize = CGSize(width: naturalSizeFirst.height, height: naturalSizeFirst.height)
        }
        else {
            renderSize = CGSize(width: naturalSizeFirst.width, height: naturalSizeFirst.width)
        }*/
        
        
        mutableVideoComposition.renderSize = CGSize(width: renderSize.width, height: renderSize.height)
        mutableVideoComposition.frameDuration = CMTimeMake(1,30)
        
        // Add TEXT
        applyVideoEffectsToComposition(composition: mutableVideoComposition, size: renderSize)
        
        // Get path
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
        exporter.videoComposition = mutableVideoComposition
        
        // 5 - Perform the Export
        exporter.exportAsynchronously() {
            
            DispatchQueue.main.async() { [weak self] _ in
                self?.exportDidFinish(session: exporter)
            }
        }
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        
        debugPrint("export did finish...")
        
        if session.status == AVAssetExportSessionStatus.completed {
            
            //self.customView.reloadPlayer()
            let outputURL = session.outputURL
            //let player:AVPlayer! = AVPlayer(url: outputURL!)
            //self.customView.playerLayer.player = player
            //let playerItem: AVPlayerItem = AVPlayerItem(url: outputURL!)
            //self.customView.playerLayer.player?.replaceCurrentItem(with: playerItem)
            //player.play()
            //self.customView.playerLayer.player?.play()
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
            }, completionHandler: { success, error in
                
                let avAsset: AVAsset = AVAsset(url: outputURL!)
                avAsset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: {
                    let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
                    self.customView.playerLayer.player?.replaceCurrentItem(with: playerItem)
                    self.customView.playerLayer.player?.play()
                })
                
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
        else {
            let title = "Error"
            let message = "Failed to save video: \(session.status.rawValue)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        videoAsset = nil
    }
}
