//
//  Animations.swift
//  Client
//
//  Created by Jordan Campbell on 4/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class AnimateTest {
    
    private var nodes: [SCNNode] = [SCNNode]()
    var rootNode: SCNNode = SCNNode()
    
    private let N = 10
    private let offsetScaleX: Float = 0.1
    private let offsetScaleY: Float = 0.05
    
    init() {
        
        for i in 0..<N {
            for k in 0..<N {
                let node = createNode("cube")
                
                node.position = SCNVector3Make((Float(i) - (Float(N-1) / 2.0)) * offsetScaleX,
                                               (Float(k) - (Float(N-1) / 2.0)) * offsetScaleY,
                                               -1.0)
                
                nodes.append(node)
                rootNode.addChildNode(node)
            }
        }
    }
    
    private func createNode(_ type: String) -> SCNNode {
        
        var geometry: SCNGeometry
        let nodeSize = 0.01
        
        switch type {
        case "sphere":
            geometry = SCNSphere(radius: CGFloat(nodeSize))
        case "cube":
            geometry = SCNBox(width: CGFloat(nodeSize),
                              height: CGFloat(nodeSize),
                              length: CGFloat(nodeSize),
                              chamferRadius: CGFloat(nodeSize*0.1))
        case "plane":
            geometry = SCNPlane(width: CGFloat(nodeSize),
                                height: CGFloat(nodeSize))
        default:
            geometry = SCNSphere(radius: CGFloat(nodeSize))
        }
        
        geometry.firstMaterial?.diffuse.contents = UIColor.magenta
        geometry.firstMaterial?.transparency = CGFloat(0.5)
        
        let node = SCNNode(geometry: geometry)
        
        return node
        
    }
    
    func saveScene() {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file = URL(fileURLWithPath: documents + "/atlas.scn")
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(self.rootNode)
        scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
        print("Scene written to: \(file)")
    }
    
    func explosion() {
        for node in self.nodes {
            
            let motion = SCNVector3Make(node.position.x, node.position.y, 0.0)
            let action = SCNAction.move(by: motion, duration: 10.0)
            
//            node.runAction(SCNAction.repeatForever(action))
            node.runAction(action)
            
        }
    }
    
}


















// end
