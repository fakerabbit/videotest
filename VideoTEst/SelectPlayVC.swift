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
        
        //self.videoOutput()
        //self.mergeVideoWithText()
        //self.mergeVideoWithText2()
        self.createComposition()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true) {
            
            if mediaType == kUTTypeMovie {
                
                let avAsset = AVAsset(url:(info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
                self.videoAsset = avAsset
                self.videoURL = (info[UIImagePickerControllerMediaURL] as! NSURL) as URL
                
                let player:AVPlayer! = AVPlayer(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
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
    
    func videoOutput() {
        
        if self.videoAsset != nil {
            
            let videoAssetTrack: AVAssetTrack = self.videoAsset!.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
            let mixComposition: AVMutableComposition = AVMutableComposition()
            let videoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            var videoAssetOrientation_ :UIImageOrientation = UIImageOrientation.up
            var isVideoAssetPortrait_ :Bool = false
            let videoTransform: CGAffineTransform = videoAssetTrack.preferredTransform
            let videolayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            let mainInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, (self.videoAsset?.duration)!)
            
            if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ = UIImageOrientation.right;
                isVideoAssetPortrait_ = true;
            }
            if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ =  UIImageOrientation.left;
                isVideoAssetPortrait_ = true;
            }
            if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
                videoAssetOrientation_ =  UIImageOrientation.up;
            }
            if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
                videoAssetOrientation_ = UIImageOrientation.down;
            }
            
            videolayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: kCMTimeZero)
            videolayerInstruction.setOpacity(0.0, at: (self.videoAsset?.duration)!)
            
            mainInstruction.layerInstructions = [videolayerInstruction]
            //mainInstruction.layerInstructions = NSArray(object: videolayerInstruction) as! [AVVideoCompositionLayerInstruction]
            
            let mainCompositionInst: AVMutableVideoComposition = AVMutableVideoComposition()
            var renderWidth: CGFloat = 0
            var renderHeight: CGFloat = 0
            var naturalSize = videoAssetTrack.naturalSize
            
            if isVideoAssetPortrait_ == true {
                naturalSize = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
            }
            
            renderWidth = naturalSize.width
            renderHeight = naturalSize.height
            
            mainCompositionInst.renderSize = CGSize(width: renderWidth, height: renderHeight)
            mainCompositionInst.instructions = [mainInstruction]
            //mainCompositionInst.instructions = NSArray(object: mainInstruction) as! [AVVideoCompositionInstructionProtocol]
            mainCompositionInst.frameDuration = CMTimeMake(1, 30)
            
            //self.applyVideoEffectsToComposition(composition: mainCompositionInst, size: naturalSize)
            
            let subtitle1Text = CATextLayer()
            subtitle1Text.font = UIFont(name: "GillSans-UltraBold", size: 40)
            subtitle1Text.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: 100)
            subtitle1Text.string = "SIRACHA!"
            subtitle1Text.alignmentMode = kCAAlignmentCenter
            subtitle1Text.foregroundColor = UIColor.lightText.cgColor
            
            // The usual overlay
            let overlayLayer = CALayer()
            overlayLayer.addSublayer(subtitle1Text)
            overlayLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
            overlayLayer.masksToBounds = true
            
            let parentLayer = CALayer()
            parentLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
            
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer)
            
            mainCompositionInst.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            
            //let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            //let randomNum = arc4random() % 1000
            //let myPathDocs = documentsPath.strings(byAppendingPaths: ["FinalVideo.mov"])
            //let url = URL(fileURLWithPath: myPathDocs[0])
            
            /*let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            debugPrint("url export: \(url)")
            exporter?.outputURL = url
            exporter?.outputFileType = AVFileTypeQuickTimeMovie
            exporter?.shouldOptimizeForNetworkUse = true
            exporter?.videoComposition = mainCompositionInst*/
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let date = dateFormatter.string(from: NSDate() as Date)
            let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
            let url = NSURL(fileURLWithPath: savePath)
            
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
            exporter.outputURL = url as URL
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = mainCompositionInst
            
            exporter.exportAsynchronously() {
                
                let player:AVPlayer! = AVPlayer(url: exporter.outputURL!)
                self.customView.playerLayer.player = player
                player.play()
                DispatchQueue.main.async() { _ in
                    self.exportDidFinish(session: exporter)
                }
            }
        }
    }
    
    func mergeVideoWithText() {
        
        // 1. mergeComposition adds all the AVAssets
        
        let mergeComposition : AVMutableComposition = AVMutableComposition()
        let trackVideo : AVMutableCompositionTrack = mergeComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        // 3. Source tracks
        
        let sourceAsset = AVURLAsset(url: self.videoURL, options: nil)
        let sourceDuration = CMTimeRangeMake(kCMTimeZero, sourceAsset.duration)
        let vtrack = sourceAsset.tracks(withMediaType: AVMediaTypeVideo)[0] as AVAssetTrack
        //let vtrack = self.videoAsset!.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
        
        if vtrack == nil {
            return
        }
        
        let renderWidth = vtrack.naturalSize.width
        let renderHeight = vtrack.naturalSize.height
        let insertTime = kCMTimeZero
        let endTime = sourceAsset.duration
        let range = sourceDuration
        
        // append tracks
        
        //trackVideo.insertTimeRange(sourceDuration, of: vtrack, at: insertTime)
        try! trackVideo.insertTimeRange(sourceDuration, of: vtrack, at: insertTime)
        
        // 4. Add text
        
        let themeVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition(propertiesOf: sourceAsset)
        
        // 4.1 - Create AVMutableVideoCompositionInstruction
        
        var compositionInstructions = [AVMutableVideoCompositionInstruction]()
        
        let mainInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = range
        
        // 4.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        
        //let videolayerInstruction : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        //let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(vtrack)
        let videolayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: vtrack)
        videolayerInstruction.setTransform(trackVideo.preferredTransform, at: insertTime)
        videolayerInstruction.setOpacity(0.0, at: endTime)
        
        // 4.3 - Add instructions
        
        mainInstruction.layerInstructions = [videolayerInstruction]
        
        compositionInstructions.append(mainInstruction)
        
        themeVideoComposition.renderScale = 1.0
        themeVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        themeVideoComposition.frameDuration = CMTimeMake(1, 30)
        themeVideoComposition.instructions = compositionInstructions
        
        // add the theme
        
        // setup variables
        
        // add text
        
        let title = String("SIRACHA!")
        
        let titleLayer = CATextLayer()
        titleLayer.string = title
        titleLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        let fontName: CFString = "GillSans-UltraBold" as CFString
        let fontSize = CGFloat(36)
        titleLayer.font = CTFontCreateWithName(fontName, fontSize, nil)
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.foregroundColor = UIColor.white.cgColor
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        backgroundLayer.masksToBounds = true
        backgroundLayer.addSublayer(titleLayer)
        
        // 2. set parent layer and video layer
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(backgroundLayer)
        
        // 3. make animation
        
        //themeVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        // export to output url
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = NSURL(fileURLWithPath: savePath)
        
        guard let exporter = AVAssetExportSession(asset: mergeComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url as URL
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = themeVideoComposition
        //exporter.videoComposition = mergeComposition
        
        exporter.exportAsynchronously() {
            
            let player:AVPlayer! = AVPlayer(url: exporter.outputURL!)
            self.customView.playerLayer.player = player
            player.play()
            DispatchQueue.main.async() { _ in
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, size: CGSize) {
        
        // Text layer
        let subtitle1Text = CATextLayer()
        subtitle1Text.font = UIFont(name: "GillSans-UltraBold", size: 40)
        subtitle1Text.frame = CGRect(x: 0, y: 0, width: size.width, height: 100)
        subtitle1Text.string = self.customView.textField.text
        subtitle1Text.alignmentMode = kCAAlignmentCenter
        subtitle1Text.foregroundColor = UIColor.lightText.cgColor
        
        // The usual overlay
        let overlayLayer = CALayer()
        overlayLayer.addSublayer(subtitle1Text)
        overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        overlayLayer.masksToBounds = true
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }
    
    func mergeVideoWithText2() {
        
        // 1. mergeComposition adds all the AVAssets
        
        let mergeComposition : AVMutableComposition = AVMutableComposition()
        let trackVideo : AVMutableCompositionTrack = mergeComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        // 3. Source tracks
        
        let sourceDuration = CMTimeRangeMake(kCMTimeZero, (self.videoAsset?.duration)!)
        let vtrack = (self.videoAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])! as AVAssetTrack
        //let vtrack = self.videoAsset!.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
        
        if vtrack == nil {
            return
        }
        
        let renderWidth = vtrack.naturalSize.width
        let renderHeight = vtrack.naturalSize.height
        let insertTime = kCMTimeZero
        let endTime = self.videoAsset?.duration
        let range = sourceDuration
        
        // append tracks
        
        //trackVideo.insertTimeRange(sourceDuration, of: vtrack, at: insertTime)
        try! trackVideo.insertTimeRange(sourceDuration, of: vtrack, at: insertTime)
        
        // 4. Add text
        
        let themeVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition(propertiesOf: self.videoAsset!)
        
        // 4.1 - Create AVMutableVideoCompositionInstruction
        
        var compositionInstructions = [AVMutableVideoCompositionInstruction]()
        
        let mainInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = range
        
        // 4.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        
        //let videolayerInstruction : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        //let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(vtrack)
        let videolayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: vtrack)
        videolayerInstruction.setTransform(trackVideo.preferredTransform, at: insertTime)
        videolayerInstruction.setOpacity(0.0, at: endTime!)
        
        // 4.3 - Add instructions
        
        mainInstruction.layerInstructions = [videolayerInstruction]
        
        compositionInstructions.append(mainInstruction)
        
        themeVideoComposition.renderScale = 1.0
        themeVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        themeVideoComposition.frameDuration = CMTimeMake(1, 30)
        themeVideoComposition.instructions = compositionInstructions
        
        // add the theme
        
        // setup variables
        
        // add text
        
        let title = String("SIRACHA!")
        
        let titleLayer = CATextLayer()
        titleLayer.string = title
        titleLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        let fontName: CFString = "GillSans-UltraBold" as CFString
        let fontSize = CGFloat(36)
        titleLayer.font = CTFontCreateWithName(fontName, fontSize, nil)
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.foregroundColor = UIColor.white.cgColor
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        backgroundLayer.masksToBounds = true
        backgroundLayer.addSublayer(titleLayer)
        
        // 2. set parent layer and video layer
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(backgroundLayer)
        
        // 3. make animation
        
        themeVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        // export to output url
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = NSURL(fileURLWithPath: savePath)
        
        guard let exporter = AVAssetExportSession(asset: mergeComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url as URL
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = themeVideoComposition
        
        exporter.exportAsynchronously() {
            
            let player:AVPlayer! = AVPlayer(url: exporter.outputURL!)
            self.customView.playerLayer.player = player
            player.play()
            DispatchQueue.main.async() { _ in
                self.exportDidFinish(session: exporter)
            }
        }
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
        
        mutableVideoComposition.renderSize = CGSize(width: naturalSizeFirst.width, height: naturalSizeFirst.height)
        mutableVideoComposition.frameDuration = CMTimeMake(1,30)
        
        // Check the first video track's preferred transform to determine if it was recorded in portrait mode.
        
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
            DispatchQueue.main.async() { _ in
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        
        debugPrint("export did finish...")
        
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
