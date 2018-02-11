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
    
    var rootNode: SCNNode = SCNNode()
    var nodes: [Node] = [Node]()
    var requestID: String = ""
    var requestURL: String = ""
    
    let viewport: Viewport = Viewport()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    
    var renderNodeList: Set = Set<String>()
    
    init(_ requestURL: String) {
        self.requestURL = requestURL
        self.rootNode.position = SCNVector3Make(0, 0, -0.6)
    }

    func addNodeAsync(_ nodeData: Any) {
        let data: Dictionary<String, Any> = nodeData as! Dictionary<String, Any>
        
        if let key = data["key"] as? String {
            renderNodeList.insert( key )
            
            guard let node: Node = Node(data, "", 0) else {
                renderNodeList.remove( key )
                return
            }
            
            if node.canRender {
                node.render()
                self.rootNode.addChildNode(node.rootNode)
                self.nodes.append(node)
                renderNodeList.remove(key)
            } else {
                renderNodeList.remove(key)
            }
        } else {
            
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
//            performance.results()
            print("Domain scene written to: \(file)")
            exit()
        }
    }
    
    func process() {
        
        self.shiftDomainToCenter()
        print("Domain positioned at: \(self.rootNode.worldPosition )")
        
//        let renderPoll = DispatchQueue(label: "renderPoll", qos: .userInitiated)
//        renderPoll.async {
//            while(self.renderNodeList.count > 0) {}
//            self.shiftDomainToCenter()
//        }
    }
    
    func shiftDomainToCenter() {
        var mx: Float = 0.0
        var my: Float = 0.0
        
        for node in self.nodes {
            mx += node.rootNode.position.x
            my += node.rootNode.position.y
        }
        
        mx /= Float(self.nodes.count)
        my /= Float(self.nodes.count)
        
        for node in self.nodes {
            node.rootNode.position = SCNVector3Make(node.rootNode.position.x - mx,
                                                    node.rootNode.position.y - my,
                                                    node.rootNode.position.z)
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
