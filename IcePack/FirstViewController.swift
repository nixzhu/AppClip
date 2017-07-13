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

    @IBAction func createAppClip(_ sender: UIButton) {
        AppClip.create(title: "First Tab", urlScheme: "icepack://com.nixWork.IcePack/tab1")
    }
}
