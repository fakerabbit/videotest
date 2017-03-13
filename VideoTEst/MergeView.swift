//
//  MergeView.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import Foundation
import UIKit

class MergeView: UIView {
    
    lazy var loadOne: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Load asset one", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    lazy var loadTwo: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Load asset two", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    lazy var mergeSave: UIButton! = {
        let b = UIButton(type: .roundedRect)
        b.setTitle("Merge and save", for: .normal)
        b.sizeToFit()
        return b
    }()
    
    /*
     * MARK:- Init
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        self.addSubview(loadOne)
        self.addSubview(loadTwo)
        self.addSubview(mergeSave)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width
        let h = self.frame.size.height
        loadOne.frame = CGRect(x: w/2 - loadOne.frame.size.width, y: h/2 - loadOne.frame.size.height/2, width: loadOne.frame.size.width, height: loadOne.frame.size.height)
        loadTwo.frame = CGRect(x: loadOne.frame.minX, y: loadOne.frame.maxY + 20, width: loadTwo.frame.size.width, height: loadTwo.frame.size.height)
        mergeSave.frame = CGRect(x: loadOne.frame.minX, y: loadTwo.frame.maxY + 20, width: mergeSave.frame.size.width, height: mergeSave.frame.size.height)
    }
}
