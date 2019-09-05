//
//  InputController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/06/15.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Cocoa
import RGBDLib

extension Date {
    var millisecondsSince1970:Double {
        return (self.timeIntervalSince1970 * 1000.0)
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

typealias OutputUpdate = (Tool?) -> Void
var UpdateClosure: OutputUpdate = {
    guard let appli = $0 else {
        print("no application running")
    return
    }
}

typealias OutputSynthesize = (Tool?) -> Void
var SynthesizeClosure: OutputSynthesize = {
    guard let appli = $0 as! KeyFrameMapping? else {
        print("no application running")
        return
    }
}

typealias SetUpRenderer = (RGBDCamera?) -> Void
var SetUpClosure: SetUpRenderer = {
    guard let cam = $0 else {
        print("no application running")
        return
    }
}

class InputController: NSViewController, MenuDelegate {
    
    @IBOutlet var InputView: InputMetalView!
    
    @IBOutlet var mixFactorSlider: NSSlider!
    
    @IBOutlet var RenderModeButton: NSButton!
    
    @IBOutlet var smoothSlider: NSSlider!
    
    @IBOutlet weak var fpsLabel: NSTextField!
        
    var Camera: RGBDCamera?
    
    var Appli: ApplicationRGBD?
    
    var isRunning: Bool = false
    
    lazy var window: NSWindow = self.view.window!
    var location: NSPoint {
        return window.mouseLocationOutsideOfEventStream
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            //print("windowLocation:", String(format: "%.1f, %.1f", self.location.x, self.location.y))
            return $0
        }
        
        // Do any additional setup after loading the view.
        InputView.rotation = .rotate0Degrees
        InputView.mirroring = false
        
        UpdateViewClosure = {
            guard let pose = $0 else {
                print("no application running")
                return
            }
            
            if var KeyFrameMapper = self.Appli! as? KeyFrameMapping {
                KeyFrameMapper.SynthesizeView(synthPose: pose)
                UpdateClosure(KeyFrameMapper)
                return
            }
            
            if var KinFu = self.Appli! as? KinectFusion {
                KinFu.SynthesizeTSDFView(synthPose: pose)
                UpdateClosure(KinFu)
                return
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func ChangeRenderMode(_ sender: Any) {
        if (Camera != nil) {
            switch RenderModeButton.title {
            case "Depth":
                Camera!.setRenderMode(mode: .depth)
                break
            case "Normals":
                Camera!.setRenderMode(mode: .normal)
                break
            default:
                break
            }
            
            guard let inputView = InputView,
                let toDisplay = Camera!.Draw() else {
                    print("error display")
                    return
            }
            inputView.pixelBuffer = toDisplay
        }
        
        if RenderModeButton.title == "Depth" {
            RenderModeButton.title = "Normals"
            self.RenderModeButton.sizeToFit()
        } else {
            RenderModeButton.title = "Depth"
            self.RenderModeButton.sizeToFit()
        }
    }
    
    @IBAction func changeMixFactor(_ sender: NSSliderCell) {
        let mixFactor = Float(sender.intValue)/Float(sender.maxValue - sender.minValue)
        
        if (Camera != nil) {
            Camera!.changeMixFactor(mixFactor: mixFactor)
            
            guard let inputView = InputView,
                let toDisplay = Camera!.Draw() else {
                    print("error display")
                    return
            }
            inputView.pixelBuffer = toDisplay
        }
        
    }
    
    @IBAction func changeSmoothFactor(_ sender: NSSliderCell) {
        let smoothFactor = Float(sender.intValue)/Float(sender.maxValue - sender.minValue)
        
        if (Camera != nil) {
            Camera!.changeSmoothFactor(smoothFactor: smoothFactor)
            
            guard let inputView = InputView,
                let toDisplay = Camera!.Draw() else {
                    print("error display")
                    return
            }
            inputView.pixelBuffer = toDisplay
        }
    }
    
    func StartCapture() {
        
        if isRunning {
            return
        }
        
        // Load Camera
        if (Camera == nil) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            guard let camera = appDelegate.Camera as RGBDCamera? else {
                print("no camera set")
                return
            }
            Camera = camera
            
            Camera?.startRecording()
            //print ("set up intrinsics")
            //SetUpClosure(Camera)
        }
        
        // Load Application
        if (Appli == nil) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            guard let appli = appDelegate.Appli as? ApplicationRGBD? else {
                print("no camera set")
                return
            }
            Appli = appli
            Appli!.Reset()
        }
        
        UpdateClosure(Appli)
        
        isRunning = true
        var prevTime = Date().millisecondsSince1970
        var elapsedTime = Date().millisecondsSince1970
        var fpsValue = 0.0
        while (Camera!.LoadImage() && isRunning) {
            
            // Iterate the application
            Appli!.Run(camera: Camera!)
            
            if let KeyFrameMapper = Appli! as? KeyFrameMapping {
                SynthesizeClosure(KeyFrameMapper)
            } else {
                // Update the mesh
                UpdateClosure(Appli)
            }
            UpdateClosure(Appli)
            
            if let faceApp = Appli! as? FacialReconstruction {
                // draw landmarks
                guard let inputView = InputView,
                    let toDisplay = Camera!.Draw(/*faceApp.GetFaceBoundingBox(), faceApp.GetLandmarks()*/) else {
                        print("error display")
                        continue
                }
                inputView.pixelBuffer = toDisplay
            } else {
                guard let inputView = InputView,
                    let toDisplay = Camera!.Draw() else {
                        print("error display")
                        continue
                }
                inputView.pixelBuffer = toDisplay
            }
            
            // Update fps
            elapsedTime = Date().millisecondsSince1970 - prevTime
            prevTime = Date().millisecondsSince1970
            fpsValue = 1000.0/elapsedTime
            
            DispatchQueue.main.async {
                self.fpsLabel.stringValue = "\(round(fpsValue)) fps"
            }
            
            //isRunning = false
            //break
        }
    }
    
    func PauseCapture() {
        isRunning = false
    }
    
    func StopCapture() {
        isRunning = false
        if Camera == nil{
            print("No camera to stop")
            return
        }
        Camera!.endRecording()
        
        Camera!.reset()
        
        // Comparative evaluation
        if let cam = Camera! as? ICLCamera,
            let KeyFrameMapper = Appli! as? KeyFrameMapping {
            KeyFrameMapper.EvaluateKF(cam)
        }
        
        if let cam = Camera! as? ICLCamera,
            var KinFu = Appli! as? KinectFusion {
            KinFu.EvaluateKF(cam)
        }
        
        // Reset the application
        /*guard var appli = Appli as? ApplicationRGBD? else {
            print("No application to stop")
            return
        }
        appli!.Reset()
        Appli = nil*/
        Appli!.Reset()
        Appli!.Stop()
    }
    
    func RenderModel() {
        // Load Application
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        guard let tool = appDelegate.Appli as Tool? else {
            print("no camera set")
            return
        }
        
        UpdateClosure(tool)
    }
    
    func SaveMesh() {
        if let KinFu = Appli! as? KinectFusion {
            KinFu.SaveMesh()
        }
    }
}
