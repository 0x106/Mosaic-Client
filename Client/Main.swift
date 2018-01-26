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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addModel(withGestureRecognizer:)))
//        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
//        client.request(withURL: "http://90c3bbfb.ngrok.io")
        client.request(withURL: "http://www.google.co.nz/search?q=augmented+reality&oq=augmented+reality&aqs=chrome..69i57j69i60l3j69i59l2.3040j0j1&sourceid=chrome&ie=UTF-8")
    }

    func setup() {
        if !DEBUG {
            self.sceneView.scene.rootNode.addChildNode(client.rootNode)
            self.sceneView.addSubview(client.field)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: self.sceneView) {
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
                    
                    // will fail if we haven't got a domain yet
                    guard let currentDomain = client.currentDomain else {return}
                    
                    guard let tappedNode = currentDomain.getNode(withKey: nodeName) else {return}
                    if tappedNode.isButton {
                        client.request(withURL: tappedNode.href)
                    }
                }
            }
        }
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
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        if !DEBUG {
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // 1
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        // 2
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        let planeGeo = SCNPlane(width: width, height: height)
//
//        // 3
//        planeGeo.materials.first?.diffuse.contents = UIColor.magenta
//        planeGeo.materials.first?.transparency = CGFloat(0.1)
//
//        // 4
//        let planeNode = SCNNode(geometry: planeGeo)
//
//        // 5
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x,y,z)
//        planeNode.eulerAngles.x = -.pi / 2
//
//        // 6
//        node.addChildNode(planeNode)
//
//    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as?  ARPlaneAnchor,
//            let planeNode = node.childNodes.first,
//            let planeGeo = planeNode.geometry as? SCNPlane
//            else { return }
//
//        // 2
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        planeGeo.width = width
//        planeGeo.height = height
//
//        // 3
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x, y, z)
//
////        guard let currentDomain = client.currentDomain else {return}
////        currentDomain.onPlane(node)
//
//    }
//
//    @objc func addModel(withGestureRecognizer recognizer: UIGestureRecognizer) {
//        let tapLocation = recognizer.location(in: sceneView)
//
//        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
//
//        guard let hitTestResult = hitTestResults.first else { return }
//        let translation = hitTestResult.worldTransform.columns.3
//        let x = translation.x
//        let y = translation.y
//        let z = translation.z
//
////        client.rootNode.position = SCNVector3(x,y,z)
//
//        sceneView.debugOptions = []
//    }
}
