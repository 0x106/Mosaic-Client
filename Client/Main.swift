//
//  ViewController.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftyJSON

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let client = Client()
    let trackingStatus = false
    let button = UIButton()
    var clientCanMove: Bool = true
    let animate_tests = AnimateTest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(handleGestures))
        self.sceneView.addGestureRecognizer(recogniser)
        
        DEBUG = true
        if DEBUG {
//            client.request(withURL: "", false)
//            client.request(withURL: "stuff.co.nz", false)
//             client.request(withURL: "https://news.ycombinator.com")
             client.request(withURL: "google.co.nz", true)
//             client.request(withURL: "atlasreality.xyz", true)
        } else {
            // client.request(withURL: "atlasreality.xyz")
             addButton()
        }
    }

    func setup() {
        // don't run the AR session in debug mode
        if !DEBUG {
            self.sceneView.scene.rootNode.addChildNode(client.rootNode)
            self.sceneView.addSubview(client.field)
        }
    }
    
    @objc public func buttonPress() {
//        client.request(withURL: "atlasreality.xyz", true)
        client.request(withURL: "stuff.co.nz", true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: self.sceneView) {
            if self.clientCanMove {
                if let hit = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent).first{
                    let x = hit.worldTransform.columns.3.x
                    let y = hit.worldTransform.columns.3.y
                    let z = hit.worldTransform.columns.3.z + 0.0
                    
                    let translation = SCNAction.move(to: SCNVector3Make(x,y,z), duration: 2.0)
                    let rotation = SCNAction.rotateBy(x: -.pi/2.0, y: 0.0, z: 0.0, duration: 2.0)
                    
                    let motion = SCNAction.group([translation, rotation])
                    
                    self.client.rootNode.runAction(motion)
                    self.clientCanMove = false
                }
            }
            
            if let hit = self.sceneView.hitTest(touchLocation, options: nil).first {
                
                guard let nodeName = hit.node.name else {
                    return
                }
                if nodeName == "searchBarNode" {
                    client.field.becomeFirstResponder()
                } else if nodeName == "searchBarButtonNode" {
                    guard let search = client.field.text else { return }
                    client.field.resignFirstResponder()
                    client.request(withURL: search)
                } else {
                    guard let currentDomain = client.currentDomain else {return}
                    guard let tappedNode = currentDomain.getNode(withKey: nodeName) else {return}
                    if tappedNode.isButton {
                        client.request(withURL: tappedNode.href)
                    }
                }
            }
        }
    }
    
    @objc func handleGestures(_ gesture: UIPanGestureRecognizer) {
        let touch = gesture.location(in: self.sceneView)
        let velocity = gesture.velocity(in: self.sceneView)
        self.client.currentDomain?.scroll( velocity )
        if let _ = self.sceneView.hitTest(touch, types: ARHitTestResult.ResultType.featurePoint).first {}
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if self.trackingStatus == false {
            if let state = self.sceneView.session.currentFrame?.camera.trackingState {
                switch(state) {
                case .normal:
                    self.setup()
                case .notAvailable:
                    break
                case .limited(let _):
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // self.sceneView.debugOptions = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.automaticallyUpdatesLighting = true
        // sceneView.showsStatistics = true
        
        if !DEBUG {
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(CGFloat(0.1   ))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),CGFloat(planeAnchor.center.y),CGFloat(planeAnchor.center.z))
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard   let planeAnchor = anchor as?  ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else { return }
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),CGFloat(planeAnchor.center.y),CGFloat(planeAnchor.center.z))
    }
    
    @objc func moveSceneToPlane(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if self.clientCanMove {
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = SCNAction.move(to: SCNVector3Make(hitTestResult.worldTransform.columns.3.x,
                                                                hitTestResult.worldTransform.columns.3.y,
                                                                hitTestResult.worldTransform.columns.3.z + 0.0),
                                             duration: 2.0)
            let rotation = SCNAction.rotateBy(x: -.pi/2.0, y: 0.0, z: 0.0, duration: 2.0)
            let motion = SCNAction.group([translation, rotation])
            self.client.rootNode.runAction(motion)
        }
        self.clientCanMove = false
    }
}

extension ViewController {
    func addButton() {
        let bx = CGFloat((self.sceneView.bounds.maxX/2) - 24)
        let by = CGFloat(self.sceneView.bounds.maxY - 80)
        button.frame = CGRect(x: bx, y: by, width: CGFloat(48), height: CGFloat(48))
        button.backgroundColor = .clear
        let buttonIcon = UIImage(named: "1")
        button.setImage(buttonIcon, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.5)
        button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        self.sceneView.addSubview(button)
    }
}





