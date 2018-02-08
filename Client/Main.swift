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
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(self.handleGestures))
        self.sceneView.addGestureRecognizer(recogniser)
        
        DEBUG = true
        if DEBUG {
            performance.start("*CLIENT_REQUEST-0")
//            client.request(withURL: "google.co.nz", false)
//            client.request(withURL: "atlasreality.xyz", false)
            client.request(withURL: "stuff.co.nz")
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
//        client.request(withURL: "stuff.co.nz", true)
        performance.results()
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
}





