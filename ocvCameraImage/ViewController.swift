//
//  ViewController.swift
//  ocvCameraImage
//
//  Created by masui masanori on 2014/09/20.
//  Copyright (c) 2014年 masanori. All rights reserved.
//

import UIKit

class ViewController: UITableViewController
{
    @IBOutlet weak var btnStart: UIButton!
    var stbCameraView: UIStoryboard!
    var cvcCameraView: CameraViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移先のStoryboardの準備
        stbCameraView = UIStoryboard(name: "CameraView", bundle: nil)
        cvcCameraView = stbCameraView!.instantiateViewControllerWithIdentifier("CameraViewCtrl") as! CameraViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnStartTouched(sender: UIButton)
    {
        // 次のStoryboardを表示する
        self.presentViewController(cvcCameraView, animated:false, completion: nil)
    }

}

