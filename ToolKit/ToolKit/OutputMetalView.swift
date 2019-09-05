//
//  OutputMetalView.swift
//  ToolKit
//
//  Created by Diego Thomas on 2018/06/15.
//  Copyright © 2018 3DLab. All rights reserved.
//

import CoreMedia
import Metal
import MetalKit
import RGBDLib

enum UIMode {
    case rotation
    case translation
    case zoom
}

typealias UpdateViewer = (Matrix4?) -> Void
var UpdateViewClosure: UpdateViewer = {
    guard let pose = $0 else {
        print("no mesh to update")
        return
    }
}

class OutputMetalView: MTKView {
    
    var objectToDraw: Mesh!
    
    var pipelineState: MTLRenderPipelineState!
    
    var commandQueue: MTLCommandQueue!
    
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    var synthesize = false
    
    var ModeFlag: UIMode = .rotation
    var flag: Bool = true
    override var acceptsFirstResponder : Bool {
        return true
    }
    
    var modelViewMatrix: Matrix4!
    var projectionMatrix: Matrix4!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //isPaused = true
        enableSetNeedsDisplay = false
        
        device = MTLCreateSystemDefaultDevice()
        
        configureMetal()
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.drawableSize.width / self.drawableSize.height), nearZ: 0.01, farZ: 100.0)
        modelViewMatrix = Matrix4()
        
        colorPixelFormat = .bgra8Unorm
        
        objectToDraw = Mesh(name: "OutputMesh", commandQ: commandQueue, device: device!)
        
        UpdateClosure = {
            guard let appli = $0 else {
                print("no application running")
                return
            }
            appli.UpdateMesh(mesh: self.objectToDraw)
        }
        
         SetUpClosure = {
            guard let cam = $0 else {
                print("no application running")
                return
            }
            self.setProjectionMatrix(intrinsic: cam.intrinsicDepth)
        }
        
        SynthesizeClosure = {
            if var KeyFrameMapper = $0! as? KeyFrameMapping {
                if self.synthesize {
                    //KeyFrameMapper.SynthesizeView(synthPose: self.modelViewMatrix)
                    self.synthesize = false
                    KeyFrameMapper.UpdateMesh(mesh: self.objectToDraw)
                }
                return
            }
            
            if var KinFu = $0! as? KinectFusion {
                if self.synthesize {
                    //KinFu.SynthesizeTSDFView(synthPose: self.modelViewMatrix)
                    self.synthesize = false
                    KinFu.UpdateMesh(mesh: self.objectToDraw)
                }
                return
            }
        }
        
        /*let panGesture = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
         addGestureRecognizer(panGesture)*/
        
    }
    
    func setProjectionMatrix(intrinsic: [Double]) {
        var intrinsicFloat: [Float] = []
        for _ in 0...16 {
            intrinsicFloat.append(Float(0.0))
        }
        
        intrinsicFloat[0] = Float(intrinsic[0])
        intrinsicFloat[5] = Float(intrinsic[4])
        intrinsicFloat[8] = Float(intrinsic[2])
        intrinsicFloat[9] = Float(intrinsic[5])
        intrinsicFloat[10] = Float(1.0)
        intrinsicFloat[15] = Float(1.0)
        memcpy(projectionMatrix.raw(), UnsafeMutableRawPointer(&intrinsicFloat), MemoryLayout<Float>.size * 16)
    }
    
    func setModelViewMatrix(_ pose: float4x4) {
        var poseTmp: [Float] = []
        for _ in 0...16 {
            poseTmp.append(Float(0.0))
        }
        
        poseTmp[0] = pose.columns.0.x
        poseTmp[1] = pose.columns.0.y
        poseTmp[2] = pose.columns.0.z
        poseTmp[3] = pose.columns.0.w
        
        poseTmp[4] = pose.columns.1.x
        poseTmp[5] = pose.columns.1.y
        poseTmp[6] = pose.columns.1.z
        poseTmp[7] = pose.columns.1.w
        
        poseTmp[8] = pose.columns.2.x
        poseTmp[9] = pose.columns.2.y
        poseTmp[10] = pose.columns.2.z
        poseTmp[11] = pose.columns.2.w
        
        poseTmp[12] = pose.columns.3.x
        poseTmp[13] = pose.columns.3.y
        poseTmp[14] = pose.columns.3.z
        poseTmp[15] = pose.columns.3.w
        
        memcpy(modelViewMatrix.raw(), UnsafeMutableRawPointer(&poseTmp), MemoryLayout<Float>.size * 16)
    }
    
    func configureMetal() {
        
        let defaultLibrary = device!.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "model_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "model_vertex")
        //let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        //let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            print ("Create pipeline state")
        } catch {
            fatalError("Unable to create preview Metal view pipeline state. (\(error))")
        }
        
        commandQueue = device!.makeCommandQueue()
    }
    
    
    func loadData(dataSize: Int, indices: MTLBuffer) {
        print("Object loaded")
    }
    
    override func draw(_ rect: CGRect) {
        if !objectToDraw.readyToDraw() {
            return
        }
        
        guard let drawable = currentDrawable else { return }
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: modelViewMatrix, projectionMatrix: projectionMatrix, flag: flag)
        
    }
    
    /*override func mouseDown(with theEvent: NSEvent) {
     print("left mouse")
     }
     
     override func mouseDragged(with event: NSEvent) {
     print("Dragging")
     }
     
     override func swipe(with event: NSEvent) {
     print("swipe")
     }*/
    
    override func keyDown(with event: NSEvent) {
        let character = Int(event.keyCode)
        switch character {
        case 0x0D: // w
            modelViewMatrix.translate(0.0, y: 0.0, z: 0.005)
            UpdateViewClosure(modelViewMatrix)
            break
        case 0x02: // d
            modelViewMatrix.translate(-0.005, y: 0.0, z: 0.0)
            UpdateViewClosure(modelViewMatrix)
            break
        case 0x00: // a
            modelViewMatrix.translate(0.005, y: 0.0, z: 0.0)
            UpdateViewClosure(modelViewMatrix)
            break
        case 0x01: // s
            modelViewMatrix.translate(0.0, y: 0.0, z: -0.005)
            UpdateViewClosure(modelViewMatrix)
            break
        case 48:
            ModeFlag = .translation
            break
        case 53:
            modelViewMatrix = Matrix4()
            break
        default:
            break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        let character = Int(event.keyCode)
        switch character {
        case 0x0F: // r
            UpdateViewClosure(modelViewMatrix)
            break
        case 48:
            ModeFlag = .rotation
            break
        default:
            break
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        switch ModeFlag {
        case .rotation:
            ModeFlag = .zoom
            break
        case .zoom:
            ModeFlag = .rotation
            break
        default:
            ModeFlag = .zoom
            break
        }
        super.otherMouseDown(with: event)
        
    }
    
    @IBAction func handlePan(_ sender: AnyObject) {
        let recognizer = (sender as! NSPanGestureRecognizer)
        let velocity = recognizer.velocity(in: self)
        
        // set rotation angles corresponding to translation
        let angley: Float = 0.0002*Float(velocity.x)
        
        let anglex: Float = 0.0002*Float(velocity.y)
        
        switch ModeFlag {
        case .rotation:
            modelViewMatrix.rotateAroundX(0.0, y: angley, z: 0.0)
            modelViewMatrix.rotateAroundX(anglex, y: 0.0, z: 0.0)
            break
        case .translation:
            modelViewMatrix.translate(angley/2, y: -anglex/2, z: 0.0)
            break
        case .zoom:
            modelViewMatrix.translate(0.0, y: 0.0, z: (anglex+angley)/2)
            break
        }
        UpdateViewClosure(modelViewMatrix)
    }
    
    @IBAction func handleRotation(_ sender: AnyObject) {
        let recognizer = (sender as! NSRotationGestureRecognizer)
        let velocity = 0.05*Float(recognizer.rotation)
        
        modelViewMatrix.rotateAroundX(0.0, y: 0.0, z: velocity)
        UpdateViewClosure(modelViewMatrix)
    }
    
    @IBAction func handleMagnification(_ sender: AnyObject) {
        let recognizer = (sender as! NSMagnificationGestureRecognizer)
        let velocity = max(-0.9, 0.01*Float(recognizer.magnification))
        
        modelViewMatrix.translate(0.0, y: 0.0, z: velocity)
        UpdateViewClosure(modelViewMatrix)
        
    }
    
}
