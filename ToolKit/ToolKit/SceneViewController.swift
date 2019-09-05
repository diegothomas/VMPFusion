//
//  SceneViewController.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/11/29.
//  Copyright © 2018 3DLab. All rights reserved.
//

import Foundation
import SceneKit

class SceneViewController: SCNView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let scene = SCNScene.init()
        self.scene = scene
        let cameraNode = SCNNode.init()
        cameraNode.camera = SCNCamera.init()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3Make(0, 0, 300)
        cameraNode.eulerAngles = SCNVector3Make(0, 0, 0)
        cameraNode.camera?.zFar = 1000
    }
    
    func  makeScene() -> (SCNView){
        let mainView = SCNView.init(frame: self.frame)
        self.addSubview(mainView)
        let scene = SCNScene.init()
        mainView.scene = scene
        let cameraNode = SCNNode.init()
        cameraNode.camera = SCNCamera.init()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3Make(0, 0, 300)
        cameraNode.eulerAngles = SCNVector3Make(0, 0, 0)
        cameraNode.camera?.zFar = 1000
        return mainView
    }
    
    func makeViewpointObject () -> (SCNNode){
        let ViewNode = SCNNode.init()
        let ChildViewNode  = SCNNode.init()
        let scnpy = SCNPyramid.init(width: 8, height: 6, length: 8)
        ChildViewNode.geometry = scnpy
        scnpy.firstMaterial?.diffuse.contents =  NSColor.init(calibratedRed: 1.0, green: 0, blue: 0, alpha: 0.5)
        ChildViewNode.eulerAngles = SCNVector3Make(-1.57,3.14, 0)
        ViewNode.addChildNode(ChildViewNode)
        return ViewNode
    }
    
    func findKeyFrameByDis(lastKeyFrame:[String], currentFrame:[String])->(Bool){
        let distance =  powf((currentFrame[1] as NSString).floatValue - (lastKeyFrame[1] as NSString).floatValue, Float(2)) + powf((currentFrame[2] as NSString).floatValue - (lastKeyFrame[2] as NSString).floatValue, Float(2)) + powf((currentFrame[3] as NSString).floatValue - (lastKeyFrame[3] as NSString).floatValue, Float(2))
        if(Double(distance) >= 0.1){
            return true
        }else{
            return false
        }
        
    }

}
