//
//  AppDelegate.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/06/15.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Cocoa
import RGBDLib

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var Camera: RGBDCamera?
    
    var Appli: Tool?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        ParamClosure = {
            guard let params = $0 else {
                print("no application running")
                return
            }
            self.Appli = KinectFusion(height: params.GetHeight(), width: params.GetWidth(), depth: params.GetDepth(),
                                      res: params.GetResolution(), nu: params.GetTruncation(), lvl: params.GetLvl(),
                                      iter: [params.GetIter0(), params.GetIter1(), params.GetIter2()],
                                      threshDist: params.GetThreshDist(), threshAngle: params.GetThreshAngle(), videoMode: params.GetVideoCapture(),
                                      GTMode: params.GetGT(), evalMode: params.GetEval())
            print("OK KinFu")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /// This function loads a dataset that has been already loaded in a previous run
    ///
    /// - Parameters:
    ///   - sender: NSApplication
    ///   - filename: a string that contains the name of the dataset
    /// - Returns: returns true if the data has been correctly loaded
    /// - Note: if the Info.txt file does not exist then an alert message will pop out allowing to create the corresponding Info.txt file
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        print("Open Recent")
        let VideoAlert = NSAlert(error: NSError(domain: "", code: 0, userInfo: nil))
        VideoAlert.alertStyle = .informational
        VideoAlert.messageText = "Do you want to record the input Video?"
        VideoAlert.informativeText = "(If so choose the directory where the movie.mov file will be created)"
        VideoAlert.addButton(withTitle: "No")
        VideoAlert.addButton(withTitle: "Yes")
        let returnCode = VideoAlert.runModal()
        
        var videopath: URL? = nil
        if returnCode.rawValue == 1001 {
            let panelVM = NSOpenPanel()
            panelVM.allowsMultipleSelection = false
            panelVM.canChooseDirectories = true
            panelVM.canChooseFiles = false
            panelVM.resolvesAliases = true
            
            let panelTitleVM = NSLocalizedString("Choose a directory", comment: "Title for the open panel")
            panelVM.title = panelTitleVM
            
            let promptStringVM = NSLocalizedString("Choose", comment: "Prompt for the open panel prompt")
            panelVM.prompt = promptStringVM
            
            if (panelVM.runModal() == NSApplication.ModalResponse.OK) {
                videopath = panelVM.url
            }
        }
        
        do {
            let readString = try String(contentsOfFile: filename+"/Info.txt", encoding: String.Encoding.utf8)
            switch readString {
            case "Basic":
                Camera = OfflineCam(path_in: filename, VideoPath: videopath)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
            case "TUM":
                Camera = TUMCamera(path_in: filename, VideoPath: videopath)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
            case "ICL":
                Camera = ICLCamera(path_in: filename, VideoPath: videopath)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
            default:
                return false
            }
        } catch let error as NSError {
            let alert = NSAlert(error: error)
            alert.informativeText = "Make a Info.txt file that contains the name of one of the three available data format:\nBasic \nTUM \nICL \nChoose your data format"
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "ICL")
            alert.addButton(withTitle: "TUM")
            alert.addButton(withTitle: "Basic")
            let returnCode = alert.runModal()
            
            switch returnCode.rawValue {
            case 1001:
                do {
                    try "ICL".write(to: URL(fileURLWithPath: filename+"/Info.txt"), atomically: true, encoding: String.Encoding.utf8)
                    Camera = ICLCamera(path_in: filename, VideoPath: videopath)
                    NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
                } catch {
                    print("Could not create file")
                }
            case 1002:
                do {
                    try "TUM".write(to: URL(fileURLWithPath: filename+"/Info.txt"), atomically: true, encoding: String.Encoding.utf8)
                    Camera = TUMCamera(path_in: filename, VideoPath: videopath)
                    NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
                } catch {
                    print("Could not create file")
                }
                
            case 1003:
                do {
                    try "Basic".write(to: URL(fileURLWithPath: filename+"/Info.txt"), atomically: true, encoding: String.Encoding.utf8)
                    Camera = OfflineCam(path_in: filename, VideoPath: videopath)
                    NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: filename))
                } catch {
                    print("Could not create file")
                }
            default:
                return false
            }
        }
        return true
    }

    
    /// This function loads a new dataset
    ///
    /// - Parameter sender: NSApplication
    /// - Note: If the Info.txt file does not exist an alert will pop out allowing to create the file
    /// - Note: Once loaded the dataset can be found in the previous loaded menu
    @IBAction func Offline(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.resolvesAliases = true
        
        let panelTitle = NSLocalizedString("Choose a directory", comment: "Title for the open panel")
        panel.title = panelTitle
        
        let promptString = NSLocalizedString("Choose", comment: "Prompt for the open panel prompt")
        panel.prompt = promptString
        
        if (panel.runModal() == NSApplication.ModalResponse.OK) {
            let result = panel.url // pathname
            
            if (result != nil) {
                
                let VideoAlert = NSAlert(error: NSError(domain: "", code: 0, userInfo: nil))
                VideoAlert.alertStyle = .informational
                VideoAlert.messageText = "Do you want to record the input Video?"
                VideoAlert.informativeText = "(If so choose the directory where the movie.mov file will be created)"
                VideoAlert.addButton(withTitle: "No")
                VideoAlert.addButton(withTitle: "Yes")
                let returnCode = VideoAlert.runModal()
                
                var videopath: URL? = nil
                if returnCode.rawValue == 1001 {
                    let panelVM = NSOpenPanel()
                    panelVM.allowsMultipleSelection = false
                    panelVM.canChooseDirectories = true
                    panelVM.canChooseFiles = false
                    panelVM.resolvesAliases = true
                    
                    let panelTitleVM = NSLocalizedString("Choose a directory", comment: "Title for the open panel")
                    panelVM.title = panelTitleVM
                    
                    let promptStringVM = NSLocalizedString("Choose", comment: "Prompt for the open panel prompt")
                    panelVM.prompt = promptStringVM
                    if (panelVM.runModal() == NSApplication.ModalResponse.OK) {
                        videopath = panelVM.url
                    }
                }
                
                do {
                let readString = try String(contentsOfFile: result!.path+"/Info.txt", encoding: String.Encoding.utf8)
                    switch readString {
                    case "Basic":
                        Camera = OfflineCam(path_in: result!.path, VideoPath: videopath)
                        NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                    case "TUM":
                        Camera = TUMCamera(path_in: result!.path, VideoPath: videopath)
                        NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                    case "ICL":
                        Camera = ICLCamera(path_in: result!.path, VideoPath: videopath)
                        NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                    default:
                        return
                    }
                } catch let error as NSError {
                    let alert = NSAlert(error: error)
                    alert.informativeText = "Make a Info.txt file that contains the name of one of the three available data format:\nBasic \nTUM \nICL \nChoose your data format"
                    alert.addButton(withTitle: "Cancel")
                    alert.addButton(withTitle: "ICL")
                    alert.addButton(withTitle: "TUM")
                    alert.addButton(withTitle: "Basic")
                    let returnCode = alert.runModal()
                    
                    switch returnCode.rawValue {
                    case 1001:
                        do {
                            let filename = result!.appendingPathComponent("Info.txt")
                            try "ICL".write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                            Camera = ICLCamera(path_in: result!.path, VideoPath: videopath)
                            NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                        } catch {
                            print("Could not create file")
                        }
                    case 1002:
                        do {
                            let filename = result!.appendingPathComponent("Info.txt")
                            try "TUM".write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                            Camera = TUMCamera(path_in: result!.path, VideoPath: videopath)
                            NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                        } catch {
                            print("Could not create file")
                        }

                    case 1003:
                        do {
                            let filename = result!.appendingPathComponent("Info.txt")
                            try "Basic".write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                            Camera = OfflineCam(path_in: result!.path, VideoPath: videopath)
                            NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: result!.path))
                        } catch {
                            print("Could not create file")
                        }
                    default:
                        return
                    }
                }
            } else {
                // User click on "Cancel"
                return
            }
        }
        
    }
    
    
    /// This function streams RGB-D images from the Kinect V1 camera
    ///
    /// - Parameter sender: Any
    /// - Note: TBD
    @IBAction func KinectV1(_ sender: Any) {
    }
    
    /// This function streams RGB-D images from the Kinect V2 camera
    ///
    /// - Parameter sender: Any
    /// - Note: TBD
    @IBAction func KinectV2(_ sender: Any) {
    }
    
    //////////////////////////////////////////////
    ////////////// Tools menu ////////////////////
    //////////////////////////////////////////////
    
    /// This function initialise a point cloud viewer application
    /// In this application input RGB-D images are displayed as a 3D point cloud
    /// and the user can freely move around the scene
    ///
    /// - Parameter sender: Any
    @IBAction func PointCloudViewer(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
        }
        
        Appli = PCViewer()
        print("OK PCLVIEW")
    }
    
    /// Initialize a KinectFusion application
    /// KinectFusion simultaneously track camera motion, and reconstruct the 3D model with volumetric fusion
    ///
    /// - Parameter sender: Any
    /// - Note: At initialization, various parameters can be set:
    /// size of the volume, resolution,
    /// video capture enabled,
    /// Ground truth camera trajectory used,
    /// evaluation mode,
    /// ICP parameters
    @IBAction func KinFu(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
        }
        
        //Create user interface to set the parameters
        let paramPanel = ParamKinFu()
        paramPanel.show()
    }
    
    @IBAction func KFMap(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
        }
        
        Appli = KeyFrameMapping(height: 512, width: 512)
        print("OK KFMap")
    }
        
    @IBAction func DynFu(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
        }
        
        Appli = DynamicFusion(height: 200, width: 200, depth: 200)
        print("OK DynFu")
    }
    
    @IBAction func FaceReconstruction(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
        }
        
        Appli = FacialReconstruction(height: 256, width: 256)
        print("OK FaceReconstruction")
    }
    
    @IBAction func FaceFromImage(_ sender: Any) {
        if Appli != nil {
            Appli!.Stop()
            let FaceApp = Appli as? FacialModelFrom2D
            FaceApp!.Reset()
        } else {
            Appli = FacialModelFrom2D()
        }
        print("OK Face from image")
    }
    
}

