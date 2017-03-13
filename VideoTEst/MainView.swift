//
//  MainView.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import Foundation
import UIKit

class MainView: UIView {
    
    lazy var selectPlay: UIButton! = {
       let b = UIButton(type: .roundedRect)
        b.setTitle("Select and play video", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    lazy var recordSave: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Record and save video", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    lazy var mergeVideo: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Merge video", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    /*
     * MARK:- Init
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        self.addSubview(selectPlay)
        self.addSubview(recordSave)
        self.addSubview(mergeVideo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width
        let h = self.frame.size.height
        selectPlay.frame = CGRect(x: w/2 - selectPlay.frame.size.width, y: h/2 - selectPlay.frame.size.height/2, width: selectPlay.frame.size.width, height: selectPlay.frame.size.height)
        recordSave.frame = CGRect(x: selectPlay.frame.minX, y: selectPlay.frame.maxY + 20, width: recordSave.frame.size.width, height: recordSave.frame.size.height)
        mergeVideo.frame = CGRect(x: selectPlay.frame.minX, y: recordSave.frame.maxY + 20, width: mergeVideo.frame.size.width, height: mergeVideo.frame.size.height)
    }
}
