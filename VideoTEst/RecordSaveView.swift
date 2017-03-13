//
//  RecordSaveView.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import Foundation
import UIKit

class RecordSaveView: UIView {
    
    lazy var record: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Record video", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    /*
     * MARK:- Init
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        self.addSubview(record)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width
        let h = self.frame.size.height
        record.frame = CGRect(x: w/2 - record.frame.size.width, y: h/2 - record.frame.size.height/2, width: record.frame.size.width, height: record.frame.size.height)
    }
}
