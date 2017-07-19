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
        AppClip.create(title: "First View", icon: #imageLiteral(resourceName: "icon_circle"), urlScheme: "icepack://com.nixWork.IcePack/tab1", toturialImage: #imageLiteral(resourceName: "toturial"))
    }
}
