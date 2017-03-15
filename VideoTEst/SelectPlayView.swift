//
//  SelectPlayView.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer
import ICGVideoTrimmer

class SelectPlayView: UIView, UITextFieldDelegate, ICGVideoTrimmerDelegate {
    
    lazy var play: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Play video", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    lazy var videoView: UIView! = {
       let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.blue
        return v
    }()
    
    lazy var playerLayer: AVPlayerLayer! = {
       let p = AVPlayerLayer()
        p.contentsGravity = AVLayerVideoGravityResizeAspect
        return p
    }()
    
    lazy var textField: UITextField! = {
        let t = UITextField(frame: CGRect.zero)
        t.backgroundColor = UIColor.lightText
        t.delegate = self
        t.returnKeyType = .done
        return t
    }()
    
    lazy var mergeSave: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Merge and save", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    var asset: AVAsset! {
        didSet {
            self.trimmerView = ICGVideoTrimmerView(frame: CGRect.zero)
            trimmerView.asset = asset
            trimmerView.themeColor = UIColor.lightGray
            trimmerView.delegate = self
            trimmerView.showsRulerView = true
            trimmerView.trackerColor = UIColor.cyan
            self.addSubview(trimmerView)
            self.layoutSubviews()
            trimmerView.resetSubviews()
        }
    }
    
    var trimmerView: ICGVideoTrimmerView!
    
    /*
     * MARK:- Init
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        self.addSubview(play)
        self.addSubview(videoView)
        self.addSubview(textField)
        self.addSubview(mergeSave)
        videoView.layer.addSublayer(playerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width
        let h = self.frame.size.height
        play.frame = CGRect(x: w/2 - play.frame.size.width, y: h/2 - play.frame.size.height/2, width: play.frame.size.width, height: play.frame.size.height)
        videoView.frame = CGRect(x: 0, y: 0, width: w, height: play.frame.minY)
        playerLayer.frame = videoView.frame
        textField.frame = CGRect(x: play.frame.minX, y: play.frame.maxY + 10, width: w - 40, height: 40)
        mergeSave.frame = CGRect(x: play.frame.minX, y: textField.frame.maxY + 10, width: mergeSave.frame.size.width, height: mergeSave.frame.size.height)
        if trimmerView != nil {
            trimmerView.frame = CGRect(x: 0, y: mergeSave.frame.maxY + 5, width: w, height: 100)
        }
    }
    
    func reloadPlayer() {
        self.playerLayer.removeFromSuperlayer()
        self.playerLayer = AVPlayerLayer()
        videoView.layer.addSublayer(playerLayer)
        self.layoutSubviews()
    }
    
    // MARK:- TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK:- ICGVideoTrimmerDelegate 
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        
        
    }
}
