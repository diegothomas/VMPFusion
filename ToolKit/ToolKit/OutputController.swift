//
//  OutputController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/06/15.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Cocoa

class OutputController: NSViewController {
    
    @IBOutlet var OutputView: OutputMetalView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        OutputView.isPaused = false
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func SwitchRenderMode() {
        OutputView.flag = !OutputView.flag
    }
    
}
