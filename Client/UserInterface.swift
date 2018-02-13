//
//  UserInterface.swift
//  Client
//
//  Created by Jordan Campbell on 8/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

extension ViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if false {
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
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if false {
            guard   let planeAnchor = anchor as?  ARPlaneAnchor,
                    let planeNode = node.childNodes.first,
                    let plane = planeNode.geometry as? SCNPlane
            else { return }
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
            planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),CGFloat(planeAnchor.center.y),CGFloat(planeAnchor.center.z))
        }
    }
    
    @objc func moveSceneToPlane(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if false || self.clientCanMove {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: self.sceneView) {
            if false && self.clientCanMove {
                
                // Did we touch a plane?
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
            
            
            // did we hit one of the nodes that belong to the current domain?
            if let hit = self.sceneView.hitTest(touchLocation, options: nil).first {
                
                guard let nodeName = hit.node.name else {
                    return
                }
                if nodeName == "searchBarNode" {
                    
                    if client.field.isFirstResponder {
                        client.field.resignFirstResponder()
                    } else {
                        client.field.becomeFirstResponder()
                    }
                    
                } else if nodeName == "searchBarButtonNode" {
                    self.searchRequest()
                } else {
                    guard let currentDomain = client.currentDomain else {return}
                    guard let tappedNode = currentDomain.getNode(withKey: nodeName) else {return}
                    if tappedNode.isButton {
                        client.request(withURL: tappedNode.href, true)
                    }
                    if tappedNode.canReceiveUserInput {
                        
                        print("Selected an input node")
                        
                        if let currentActiveField = tappedNode.inputField {
                            print("Current active field exists for key: \(tappedNode.key)")
                            tappedNode.removeTextField(tappedNode.key)
                        } else {
                            print("Creating text field for key: \(tappedNode.key)")
                            guard let nodeField = tappedNode.addNewTextField(tappedNode.key) else {return}
                            self.sceneView.addSubview(nodeField)
                        }
                    }
                    
                    if tappedNode.nodeName == "IMG" {
                        
                        if tappedNode.rootNode.position.x < _mx {
                            let rotation = SCNAction.rotateBy(x: CGFloat(0.0), y: CGFloat(-.pi/6.0), z: CGFloat(0.0), duration: 2.0)
                            let translation = SCNAction.move(to: SCNVector3Make(_mx,
                                                                                tappedNode.rootNode.position.y,
                                                                                tappedNode.rootNode.position.z),
                                                                                duration: 2.0)
                            let motion = SCNAction.group([translation, rotation])
                            tappedNode.rootNode.runAction(motion)
                        } else {
                            let rotation = SCNAction.rotateBy(x: CGFloat(0.0), y: CGFloat(.pi/6.0), z: CGFloat(0.0), duration: 2.0)
                            let translation = SCNAction.move(to: SCNVector3Make(_mx,
                                                                                tappedNode.rootNode.position.y,
                                                                                tappedNode.rootNode.position.z),
                                                             duration: 2.0)
                            let motion = SCNAction.group([translation, rotation])
                            tappedNode.rootNode.runAction(motion)
                        }
                    }
                    
                }
            }
        }
    }
    
//    @objc func onTranslate(_ sender: UIPanGestureRecognizer) {
//
//        if let hit = self.sceneView.hitTest(sender, options: nil).first {
//
//            guard let nodeName = hit.node.name else {
//                return
//            }
//
//        }
//
//        let position = sender.location(in: self.sceneView)
//        let state = sender.state
//
//        if (state == .failed || state == .cancelled) {
//            return
//        }
//
//        if (state == .began) {
//
//
//
//            guard let currentDomain = client.currentDomain else {return}
//            guard let tappedNode = currentDomain.getNode(withKey: nodeName) else {return}
//
//            // Check it's on a virtual object
//            if let objectNode = virtualObject(at: position) {
//                // virtualObject(at searches for root node if it's a subnode
//                targetNode = objectNode
//                latestTranslatePos = position
//            }
//
//        }
//        else if let _ = targetNode {
//
//            // Translate virtual object
//            let deltaX = Float(position.x - latestTranslatePos!.x)/700
//            let deltaY = Float(position.y - latestTranslatePos!.y)/700
//
//            targetNode!.localTranslate(by: SCNVector3Make(deltaX, 0.0, deltaY))
//
//            latestTranslatePos = position
//
//            if (state == .ended) {
//                targetNode = nil
//            }
//        }
//    }
    
    @objc func handleGestures(_ gesture: UIPanGestureRecognizer) {
        let touch = gesture.location(in: self.sceneView)
        let velocity = gesture.velocity(in: self.sceneView)
        self.client.currentDomain?.scroll( velocity )
        if let _ = self.sceneView.hitTest(touch, types: ARHitTestResult.ResultType.featurePoint).first {}
    }

}
