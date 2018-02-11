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

class RenderMonitor {
    private var renderList: Set<String> = Set<String>()
    
    func open(_ key: String) {
        renderList.insert(key)
    }
    
    func close(_ key: String) -> Bool {
        if renderList.contains(key) {
            renderList.remove(key)
        }
        
        if renderList.count == 0 {
            print("RenderList is empty")
            return true
        } else {
            print(renderList)
        }
        
        return false
    }
}

class Domain {
    
    var rootNode: SCNNode = SCNNode()
    var nodes: [Node] = [Node]()
    var nodeDict: Dictionary<String, Node?> = Dictionary<String, Node?>()
    var requestID: String = ""
    var requestURL: String = ""
    
    let viewport: Viewport = Viewport()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    
    var renderNodeList: Set = Set<String>()
    var renderMonitor: RenderMonitor = RenderMonitor()
    
    var allDataSent: Bool = false
    var centered: Bool = false
    
    init(_ requestURL: String) {
        self.requestURL = requestURL
        self.rootNode.position = SCNVector3Make(0, 0, -0.6)
    }

    func addNodeAsync(_ data: Dictionary<String, Any>) {
        
        let key = data["key"] as! String
            
        guard let node: Node = Node(data, "", 0) else {
//            if self.renderMonitor.close(key) {self.process()}
            return
        }
        
        if node.canRender {
//            self.renderMonitor.open(key)
            let _ = node.render()
            self.rootNode.addChildNode(node.rootNode)
            self.nodes.append(node)
            self.nodeDict[key] = node
//            if self.renderMonitor.close(key) {self.process()}
        } else {
//            if self.renderMonitor.close(key) {self.process()}
        }
    }
    
    func getNode(withKey ref: String) -> Node? {
        
        if let node = self.nodeDict[ref] {
            if (node?.canRender)! {
                return node
            }
        }
        
        
//        for node in self.nodes {
//            if node.canRender {
//                if node.key == ref {
//                    return node
//                }
//            }
//        }
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
        
        if self.allDataSent && !self.centered {
            self.shiftDomainToCenter()
            self.centered = true
        }
        
//        let renderPoll = DispatchQueue(label: "renderPoll", qos: .userInitiated)
//        renderPoll.async {
//            while(self.renderNodeList.count > 0) {}
//            self.shiftDomainToCenter()
//            print("Domain positioned at: \(self.rootNode.worldPosition )")
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

//        self.rootNode.position = SCNVector3Make(self.rootNode.position.x - mx,
//                                                self.rootNode.position.y - my,
//                                                self.rootNode.position.z)
        
//        print(self.rootNode.position)
        
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
