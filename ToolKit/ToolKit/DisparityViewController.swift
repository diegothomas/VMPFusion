//
//  DisparityViewController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2019/01/25.
//  Copyright © 2019 3DLab. All rights reserved.
//

import Cocoa
import RGBDLib

class DisparityViewController: NSViewController {

    @IBOutlet var DisparityView: DisparityMetalView!
    
    var ReferenceImage: NSImage?
    
    var Appli: Tool?
    
    lazy var window: NSWindow = self.view.window!
    var location: NSPoint {
        return window.mouseLocationOutsideOfEventStream
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            //print("windowLocation:", String(format: "%.1f, %.1f", self.location.x, self.location.y))
            if self.location.y < 40.0 {
                self.DisparityView.gestureFlag = false
            } else {
                self.DisparityView.gestureFlag = true
            }
            return $0
        }
        
        DisparityView.rotation = .rotate0Degrees
        DisparityView.mirroring = false
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    /**
     Draw current Disp image
     */
    @IBAction func Draw(_ sender: Any) {
        // Load Application
        if (Appli == nil) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            guard let appli = appDelegate.Appli as? ApplicationRGBD? else {
                print("no application set")
                return
            }
            Appli = appli
        }
        
        let appli = Appli as! FacialReconstruction?
        
        guard let inputView = DisparityView,
            let toDisplay = appli!.DrawDisp() else {
                print("error display")
                return
        }
        inputView.pixelBuffer = toDisplay
    }
    
    
    @IBAction func ChangeMixFactor(_ sender: NSSliderCell) {
        let mixFactor = Float(sender.intValue)/Float(sender.maxValue - sender.minValue)
        
        if (Appli != nil) {
            let appli = Appli as! FacialReconstruction?
            appli!.changeMixFactor(mixFactor: mixFactor)
            
            guard let inputView = DisparityView,
                let toDisplay = appli!.DrawDisp() else {
                    print("error display")
                    return
            }
            inputView.pixelBuffer = toDisplay
        }
    }
    
}
