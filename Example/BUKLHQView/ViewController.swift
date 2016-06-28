//
//  ViewController.swift
//  BUKLHQView
//
//  Created by monzy613 on 06/28/2016.
//  Copyright (c) 2016 monzy613. All rights reserved.
//

import UIKit
import BUKLHQView

class ViewController: UIViewController, BUKLHQViewDelegate, BUKLHQViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        let lhq = BUKLHQView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        lhq.center = view.center
        lhq.delegate = self
        lhq.dataSource = self
        view.addSubview(lhq)
    }
    
    // MARK: BUKLHQViewDelegate
    func buk_lhqView(lhqView: BUKLHQView, didSelectButtonAtIndex index: Int) {
        print(index)
    }
    // MARK: BUKLHQViewDataSource
    func buk_numberOfButtonsInLHQView(lhqView: BUKLHQView) -> Int {
        return 6
    }
    
    func buk_lhqView(lhqView: BUKLHQView, titleForButtonAtIndex index: Int) -> String? {
        return "wtf"
    }
    
    func buk_lhqView(lhqView: BUKLHQView, imageForButtonAtIndex index: Int) -> UIImage? {
        return nil
    }
    
    func buk_lhqView(lhqView: BUKLHQView, titleColorForButtonAtIndex index: Int) -> UIColor? {
        return UIColor.black()
    }
}

