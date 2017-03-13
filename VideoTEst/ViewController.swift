//
//  ViewController.swift
//  VideoTEst
//
//  Created by Mirko Justiniano on 3/9/17.
//  Copyright © 2017 VT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var mainView:MainView! = {
        let frame = UIScreen.main.bounds
        let v = MainView(frame: frame)
        return v
    }()
    
    // MARK:- View methods
    
    override func loadView() {
        super.loadView()
        self.view = self.mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "VIDEO TEST"
        self.mainView.selectPlay.addTarget(self, action: #selector(onSelectPlay(_:)), for: .touchUpInside)
        self.mainView.recordSave.addTarget(self, action: #selector(onRecordSave(_:)), for: .touchUpInside)
        self.mainView.mergeVideo.addTarget(self, action: #selector(onMerge(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Handlers
    
    func onSelectPlay(_ sender: UIButton) {
        let vc = SelectPlayVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onRecordSave(_ sender: UIButton) {
        let vc = RecordSaveVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onMerge(_ sender: UIButton) {
        let vc = MergeVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

