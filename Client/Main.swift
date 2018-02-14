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
import Alamofire
import AlamofireImage
var searchButtonVisible: Bool = false

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!

    let client = Client()
    var trackingStatus = false
    let button = UIButton()
    let animationButton = UIButton()
    var clientCanMove: Bool = true
    var focus: FocusRing = FocusRing()
    var _mx: Float = 0.0

    var scaledNodes: [SCNNode] = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self

        let scene = SCNScene()
        sceneView.scene = scene

        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(self.handleGestures))
        self.sceneView.addGestureRecognizer(recogniser)
        
        self.sceneView.scene.rootNode.addChildNode(focus.rootNode)
        focus.rootNode.isHidden = true

        initConfig()
    }
    
    func setup() {
        // don't run the AR session in debug mode
        if !DEBUG {
            self.sceneView.scene.rootNode.addChildNode(client.rootNode)
            self.sceneView.addSubview(client.field)
            self.addButton()
        }
    }

    @objc public func buttonPress() {
        if self.client.searchBar.rootNode.isHidden {
            self.client.currentDomain?.rootNode.isHidden = true
           self.client.searchBar.rootNode.isHidden = false
        } else {
            self.searchRequest()
        }
    }
    
    @objc public func animationButtonPress() {
        
        guard let domain = self.client.currentDomain else {return}
        
        if domain.nodes.count == 0 {
            return
        }
        
        var mx: Float = 0.0
        var sx: Float = 0.0
        for node in domain.nodes {
            mx += node.rootNode.position.x
        }
        
        mx /= Float(domain.nodes.count)
        
        for node in domain.nodes {
            sx += ((node.rootNode.position.x - mx) * (node.rootNode.position.x - mx))
        }
        
        sx /= Float(domain.nodes.count)
        
        _mx = mx
        
        for node in domain.nodes {
            
            if node.rootNode.position.x < (mx - (0.9 * sx)) {
                let rotation = SCNAction.rotateBy(x: CGFloat(0.0), y: CGFloat( (mx - node.rootNode.position.x) * (.pi/6.0) ), z: CGFloat(0.0), duration: 2.0)
                let translation = SCNAction.move(by: SCNVector3Make(-0.4, 0.0, 0.2), duration: 2.0)
                let motion = SCNAction.group([translation, rotation])
                node.rootNode.runAction(motion)
            } else if node.rootNode.position.x > (mx + (0.9 * sx)) {
                let rotation = SCNAction.rotateBy(x: CGFloat(0.0), y: CGFloat((node.rootNode.position.x - mx) * (-.pi/6.0)), z: CGFloat(0.0), duration: 2.0)
                let translation = SCNAction.move(by: SCNVector3Make(0.4, 0.0, 0.2), duration: 2.0)
                let motion = SCNAction.group([translation, rotation])
                node.rootNode.runAction(motion)
            } else {
                
            }
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if self.trackingStatus == false {
            if let state = self.sceneView.session.currentFrame?.camera.trackingState {
                switch(state) {
                case .normal:
                    self.trackingStatus = true
                    self.setup()
                case .notAvailable:
                    break
                case .limited:
                    break
                }
            }
        }
        
        // if tracking has been established
        else {
            
//            print("Client: \(self.client.rootNode.worldPosition)")
//            print("Domain: \(self.client.currentDomain?.rootNode.worldPosition)")
//            print("=================================")
            
            let center = self.sceneView.center

            if let domain = self.client.currentDomain {

//                domain.process()

                if let hit = self.sceneView.hitTest(center, options: nil).first {
                    if let nodeName = hit.node.name {
                        if let node = domain.getNode(withKey: nodeName) {
                            
                            focus.rootNode.isHidden = false

                            if node.nodeName == "#text" {
                                let position = node.rootNode.worldPosition
                                let eulerAngles = SCNVector3(frame.camera.eulerAngles)
                                focus.set(position, eulerAngles)
                                
                                for n in scaledNodes {
                                    n.scale = SCNVector3Make(1.0, 1.0, 1.0)
                                }
                                
                                node.rootNode.scale = SCNVector3Make(2.0, 2.0, 2.0)
                                scaledNodes.append(node.rootNode)
                                
                            }
                            // if a node gets moved then all its children have to as well.

//                            for domainNode in (self.client.currentDomain?.nodes)! {
//                                if distance(domainNode.rootNode.position, node.rootNode.position) < 0.5 {
//                                    domainNode.setActive()
//                                }
//                            }
//
//                            node.setActive()

                        }
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

//        self.sceneView.debugOptions = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
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

    func addButton() {
        let bx = CGFloat((self.sceneView.bounds.maxX/2) - 24)
        let by = CGFloat(self.sceneView.bounds.maxY - 80)
        button.frame = CGRect(x: bx, y: by, width: CGFloat(48), height: CGFloat(48))
        button.backgroundColor = .clear

        if let buttonIcon = UIImage(named: "search") {
            button.setImage(buttonIcon, for: .normal)
            button.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.0)
            button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            self.sceneView.addSubview(button)
        }
        
        let bx2 = CGFloat((self.sceneView.bounds.midX/2) - 24)
        let by2 = CGFloat(self.sceneView.bounds.maxY - 80)
        animationButton.frame = CGRect(x: bx2, y: by2, width: CGFloat(48), height: CGFloat(48))
        animationButton.backgroundColor = .clear
        
        // https://www.flaticon.com/authors/zlatko-najdenovski - robot button author
        if let buttonIcon = UIImage(named: "robot") {
            animationButton.setImage(buttonIcon, for: .normal)
            animationButton.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.0)
            animationButton.addTarget(self, action: #selector(animationButtonPress), for: .touchUpInside)
            animationButton.layer.cornerRadius = 0.5 * button.bounds.size.width
            animationButton.clipsToBounds = true
            self.sceneView.addSubview(animationButton)
        }
        
    }

    func searchRequest() {
        guard var search = client.field.text else { return }

        if search == "" {
            search = client.defaultSearchURL
        }

        client.field.resignFirstResponder()
        client.request(withURL: search, true)
    }

}
