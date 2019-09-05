//
//  WindowController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/06/15.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Cocoa
import RGBDLib

protocol MenuDelegate: class {
    func StartCapture()
}

class WindowController: NSWindowController {

    weak var inputControllerDelegate: MenuDelegate?
    
    var splitView: SplitViewController?
    
    var inputView: InputController?
    
    var outputView: OutputController?
    
    @IBOutlet var ToolName: NSTextFieldCell!
    
    private let sessionQueue = DispatchQueue(label: "session queue", qos: DispatchQoS.userInitiated, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .workItem)
    
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        //window?.titleVisibility = .hidden
        
        splitView = self.contentViewController as? SplitViewController
        
        inputView = splitView?.children.first as? InputController
        
        outputView = splitView?.children.last as? OutputController
    }
    
    @IBAction func StartApp(_ sender: Any) {
        sessionQueue.async {
            self.inputView?.StartCapture()
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        guard let appli = appDelegate.Appli as Tool? else {
            print("no application set")
            return
        }
        ToolName.title = appli.label
    }
    
    @IBAction func PauseApp(_ sender: Any) {
        sessionQueue.async {
            self.inputView?.PauseCapture()
        }
    }
    
    @IBAction func StopApp(_ sender: Any) {
        sessionQueue.async {
            self.inputView?.StopCapture()
        }
    }
    
    @IBAction func RenderMode(_ sender: Any) {
        sessionQueue.async {
            self.outputView?.SwitchRenderMode()
        }
    }
    
    @IBAction func Render(_ sender: Any) {
        sessionQueue.async {
            self.inputView?.RenderModel()
        }
    }
    
    @IBAction func SetCenter(_ sender: Any) {
        sessionQueue.async {
            //self.inputView?.RenderModel()
        }
    }
    
    
    @IBAction func SaveMesh(_ sender: Any) {
        self.inputView?.SaveMesh()
    }
}
