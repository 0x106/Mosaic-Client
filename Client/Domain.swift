//
//  Domain.swift
//  Client
//
//  Created by Jordan Campbell on 26/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

class Domain {
    
    var data: JSON!
    var rootKey: String = ""
    var rootNode: SCNNode = SCNNode()
    var nodes: [Node] = [Node]()
    var requestID: String = ""
    var requestURL: String = ""
    
    let viewport: Viewport = Viewport()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    var isReady: Bool = false
    var maxZOffset: Float = 0.0
    
    init(_ requestURL: String) {
        self.requestURL = requestURL
    }

    func addNodeAsync(_ nodeData: Any) {
        let data: Dictionary<String, Any> = nodeData as! Dictionary<String, Any>
        print("Adding new node with key: \(data["key"]!)")
            
        guard let node: Node = Node(data, "", 0) else {return}
        
        if node.canRender {
            node.render()
            self.rootNode.addChildNode(node.rootNode)
            self.nodes.append(node)
        }
    }
    
    func getNode(withKey ref: String) -> Node? {
        for node in self.nodes {
            if node.canRender {
                if node.key == ref {
                    return node
                }
            }
        }
        return nil
    }

    func scroll(_ velocity: CGPoint) {
        self.rootNode.position.y -= Float(velocity.y) * self.velocityScale
        update()
    }

    func update() {
//        let updateWorker = DispatchQueue(label: "updateWorker", qos: .userInitiated)
//        updateWorker.async {
//            for element in self.nodes {
//                if self.viewport.contains(element.rootNode.worldPosition) {
//
//                    if !element.isRendered {
//                        element.draw()
//                    }
//                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(1.0)
//                } else {
////                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(0.2)
//                }
//            }
//
//        }
    }
    
    func writeSceneToFile() {
        if DEBUG {
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let file = URL(fileURLWithPath: documents + "/\(globalRequestID).scn")
            
            let scene = SCNScene()
            scene.rootNode.addChildNode(self.rootNode)
            scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
            performance.results()
            print("Domain scene written to: \(file)")
            exit()
        }
    }
    
    
}


class Viewport {
    
    var x: [Float]
    var y: [Float]
    var z: [Float]

    init() {
        // set the initial view parameters
        x = [-0.65, 0.65]
        y = [-0.65, 0.65]
        z = [-2.0, 2.0]
    }
    
    func contains(_ position: SCNVector3) -> Bool {
        if     (position.x >= self.x[0] && position.x <= self.x[1])
            && (position.y >= self.y[0] && position.y <= self.y[1])
            && (position.z >= self.z[0] && position.z <= self.z[1]) {
            
            return true
        }
        
        return false
    }

}






// end
