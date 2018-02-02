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
        
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(handleGestures))
        self.sceneView.addGestureRecognizer(recogniser)
        
        DEBUG = false
        if DEBUG {
//            client.request(withURL: "", false)
//            client.request(withURL: "https://www.google.co.nz/search?q=augmented+reality&oq=augmented+reality&aqs=chrome..69i57j69i60l3j0j69i59.5831j0j1&sourceid=chrome&ie=UTF-8")
//            client.request(withURL: "https://news.ycombinator.com/newest", true)
//            client.request(withURL: "https://betaworks.com/", false)
            client.request(withURL: "https://academy.realm.io/posts/3d-graphics-metal-swift/", false)
        } else {
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
    
    @objc func handleGestures(_ gesture: UIPanGestureRecognizer) {
        print("~~~~ Panning ~~~~")
        
        let touch = gesture.location(in: self.sceneView)
        let velocity = gesture.velocity(in: self.sceneView)
        
        print("touch: \(touch)")
        print("velocity: \(velocity)")
        
        self.client.currentDomain?.scroll( velocity )
        
        if let hit = self.sceneView.hitTest(touch, types: ARHitTestResult.ResultType.featurePoint).first {

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
        if !DEBUG { // don't run the AR session in debug mode
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
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
}


extension ViewController {
    func addButton() {
        let bx = CGFloat((self.sceneView.bounds.maxX/2) - 24)
        let by = CGFloat(self.sceneView.bounds.maxY - 80)
        button.frame = CGRect(x: bx, y: by, width: CGFloat(48), height: CGFloat(48))
        button.backgroundColor = .clear
        let buttonIcon = UIImage(named: "add")
        button.setImage(buttonIcon, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.5)
        button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        self.sceneView.addSubview(button)
    }
}





