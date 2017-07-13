//
//  FirstViewController.swift
//  IcePack
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import UIKit
import AppClip

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func createAppClip(_ sender: UIButton) {
        AppClip.create(urlScheme: "icepack://com.nixWork.IcePack/new")
    }
}
