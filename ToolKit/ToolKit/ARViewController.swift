//
//  ARViewController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/11/29.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Cocoa
import SceneKit
import RGBDLib

class ARViewController: NSViewController {
    
    var Camera: TUMCamera?

    @IBOutlet weak var scnview: SceneViewController! {
        willSet {
            newValue.allowsCameraControl = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        guard let camera = appDelegate.Camera as? TUMCamera else {
            print("no TUMCamera set")
            return
        }
        Camera = camera
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
