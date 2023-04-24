//
//  GameViewController.swift
//  ARMajic
//
//  Created by Attharva Kulkarni on 16/03/23.
//  Copyright © 2023 Attharva Kulkarni. All rights reserved.
//


import UIKit
import ARKit
import LBTAComponents


class GameViewController:UIViewController,ARSCNViewDelegate {
    
    
    var nodesPosition = SCNVector3()
    var nodesAngle = SCNVector3()
    
    var tumor = SCNNode()
    var brain = SCNNode()
    
    
    var trackNode = SCNNode()
    
    
    
    let arView: ARSCNView = {
        
        let view = ARSCNView()
        return view
        
    }()
    
    
    var planeGeometry:SCNPlane!
    var anchors = [ARAnchor]()
    
    
    let TapButtonWidth = ScreenSize.width * 0.1
    lazy var addObject: UIButton = {
        var button = UIButton(type: .system)
        
        button.setTitle("Tap", for: .normal)
        button.addTarget(self, action: #selector(handleTapButtontapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        return button
        
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.addTarget(self, action: #selector(handleResetButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    
    let minScale: Float = 0.001 // Adjust this value as needed
    let maxScale: Float = 0.1 // Adjust this value as needed
    
    
    
    @objc func handleTapButtontapped() {
        var doesNodeExists = false

        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "trackNode" {
                doesNodeExists = true
                print("already exists")
            }
        }

        if !doesNodeExists {
            addScene()
            print("doesnt exists")
        }

        addObject.isHidden = doesNodeExists
    }

    
    
    let labelDes:UILabel = {
        
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.white.withAlphaComponent(1)
        label.text = " Brain Tumor "
        
        
        return label
        
    }()
    
    
    let labelDescription:UILabel = {
        
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        label.textColor = UIColor.black
        label.text = ""
        label.layer.borderWidth = 2
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        label.layer.cornerRadius = 1
        
        
        return label
    }()
    
    
 
    
    
    
    
    var configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let scene = SCNScene(named: "art.scnassets/brainAnatomy.scn")!
        
        arView.scene = scene
        
        
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject))
        
        arView.addGestureRecognizer(pinchGestureRecognizer)
        
        
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        
        arView.addGestureRecognizer(rotateGestureRecognizer)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configuration.planeDetection = .horizontal
        
        arView.session.run(configuration)
        
        setupViews()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    var didInitializeScene:Bool = false
    
    
    
    
    func setupViews(){
        
        
        
        view.addSubview(arView)
        
        arView.fillSuperview()
        
        
        view.addSubview(addObject)
        addObject.anchor(nil, left:nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right:nil,topConstant: 0,leftConstant: 0,bottomConstant: 12,rightConstant: 0, widthConstant: TapButtonWidth, heightConstant:  TapButtonWidth)
        addObject.anchorCenterXToSuperview()
        
        
        view.addSubview(labelDes)
        labelDes.anchor(view.safeAreaLayoutGuide.topAnchor, left:view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right:nil,topConstant:30,leftConstant: 40,bottomConstant: 0,rightConstant: 0, widthConstant: 0, heightConstant:24)
        
        view.addSubview(labelDescription)
        labelDescription.anchor(labelDes.bottomAnchor, left:view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right:nil,topConstant:30,leftConstant: 40,bottomConstant: 0,rightConstant: 0, widthConstant: 0, heightConstant:24)
        
        view.addSubview(resetButton)
        resetButton.anchor(nil, left:view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right:nil,topConstant:0,leftConstant: 40,bottomConstant: 12,rightConstant: 0, widthConstant: TapButtonWidth, heightConstant:TapButtonWidth)
       
        

        
    }
    
    
    
    func  addScene(){
        
        if !didInitializeScene{
            
            if let cameraHeat = arView.session.currentFrame?.camera{
                didInitializeScene = true
                
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1
                translation.columns.3.y = -0.1
                translation.columns.3.x = 0.0
                
                
                
                
                let transform = cameraHeat.transform * translation
                
                self.nodesPosition = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                
                
                
                
                nodesAngle = SCNVector3Make(0,Float(180.degreesToRadians), 0)
                
                
            }
            
        }
        
        
        brain = arView.scene.rootNode.childNode(withName: "SegmentationBrain", recursively: false)!
        
        brain.name = "Brain"
        brain.isHidden = false
        
        brain.geometry?.firstMaterial?.isDoubleSided = true
        
        
        brain.position = nodesPosition
        
        brain.eulerAngles = nodesAngle
        
        
        brain.scale = SCNVector3(0.004, 0.004, 0.004)
        arView.scene.rootNode.addChildNode(brain)
        
        
        
        tumor = arView.scene.rootNode.childNode(withName: "SegmentationTumor", recursively: false)!
        
        
        tumor.name = "Meningioma Tumor, it affects Persoanlity, Movement and Sense of Smell."
        tumor.isHidden = false
        
        tumor.geometry?.firstMaterial?.isDoubleSided = true
        
        
        tumor.position = nodesPosition
        
        tumor.eulerAngles = nodesAngle
        
        
        tumor.scale = SCNVector3(0.004, 0.004, 0.004)
        arView.scene.rootNode.addChildNode(tumor)
          
        
        trackNode.geometry = SCNSphere(radius:0.000001)
        trackNode.position = nodesPosition
        trackNode.name = "trackNode"
        
        arView.scene.rootNode.addChildNode(trackNode)
        
    
    }
    
    
    var brainMoved = false

    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tappedView = sender.view as! SCNView
        let touchLocation = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(touchLocation, options: nil)

        if let result = hitTest.first {
            if let name = result.node.name {
                self.labelDescription.text = String("  You have tapped on \(name)  ")
            }

            // Brain
            if result.node.name == "Brain" {
                if !brainMoved {
                    let moveAction = SCNAction.move(by: SCNVector3(0, 0, 0.5), duration: 0.5)
                    moveAction.timingMode = .easeInEaseOut
                    brain.runAction(moveAction)
                    brainMoved = true
                } else {
                    let moveAction = SCNAction.move(by: SCNVector3(0, 0, -0.5), duration: 0.5)
                    moveAction.timingMode = .easeInEaseOut
                    brain.runAction(moveAction)
                    brainMoved = false
                }
            }
        }
    }

    
    
    
    
    @objc func handleResetButtonTapped() {
        // Get the current camera position
        guard let camera = arView.session.currentFrame?.camera else {
            return
        }
        
        // Calculate the new position for the AR model
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1
        translation.columns.3.y = -0.1
        translation.columns.3.x = 0.0
        let transform = camera.transform * translation
        let newPosition = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        // Update the position of the AR model
        brain.position = newPosition
        tumor.position = newPosition
        trackNode.position = newPosition
        
        // Reset the rotation, if necessary
         brain.eulerAngles = nodesAngle
         tumor.eulerAngles = nodesAngle
    }
    

    
    @objc func scaleObject(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((brain.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((brain.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((brain.scale.z))
            
            let newScaleX = Float(pinchScaleX)
            let newScaleY = Float(pinchScaleY)
            let newScaleZ = Float(pinchScaleZ)
            
            if newScaleX >= minScale && newScaleX <= maxScale &&
                newScaleY >= minScale && newScaleY <= maxScale &&
                newScaleZ >= minScale && newScaleZ <= maxScale {
                brain.scale = SCNVector3(newScaleX, newScaleY, newScaleZ)
                tumor.scale = SCNVector3(newScaleX, newScaleY, newScaleZ)
            }
            
            gesture.scale = 1
        }
        
        if gesture.state == .ended {
            
        }
    }
    
    
    
    @objc func rotateNode(_ gesture:UIRotationGestureRecognizer){
        var machine2:Float = 0.0
        
        let rotation = Float(gesture.rotation)
        
        
        if gesture.state == .changed{
            
            
            
            brain.eulerAngles.y = machine2 + rotation
            
            tumor.eulerAngles.y = machine2 + rotation
            
            
        }
        
        if(gesture.state == .ended){
            
            
            machine2 = brain.eulerAngles.y
            
            machine2 = tumor.eulerAngles.y
            
            
        }
        
        
    }
    
    
    
}











