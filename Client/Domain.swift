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
    
    let configManager: ConfigManager = ConfigManager()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    
    var renderNodeList: Set = Set<String>()
    var renderMonitor: RenderMonitor = RenderMonitor()
    
    var allDataSent: Bool = false
    var centered: Bool = false
    
    var centerTimer: Timer!

    init(_ requestURL: String) {
        self.requestURL = requestURL
        self.rootNode.position = SCNVector3Make(0, 0, -0.6)
        centerTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(shiftDomainToCenter), userInfo: nil, repeats: true)
    }

    func addNodeAsync(_ data: Dictionary<String, Any>) {
        
        let key = data["key"] as! String
        
        if let type = data["nodeName"] as? String {
            if AFrameTypes.contains(type) {
                guard let node: AFrame = AFrame(data, self.requestURL, 0) else {return}
                renderNode(node, key)
            } else {
                guard let node: Node = Node(data, self.requestURL, 0, self.configManager.config_data) else {
                    return
                }
                renderNode(node, key)
            }
        }
    }
    
    func renderNode(_ node: Node, _ key: String) {
//        if node.canRender || node.forceRender {
            let _ = node.render()
            self.rootNode.addChildNode(node.rootNode)
            self.nodes.append(node)
            self.nodeDict[key] = node
//        }
    }
    
    func getNode(withKey ref: String) -> Node? {
        
        if let node = self.nodeDict[ref] {
            if (node?.canRender)! {
                return node
            }
        }
        
        return nil
    }
    
    func getParentofSCNNode(_ _child: SCNNode) -> Node? {
        for node in self.nodes {
            if let childName = _child.name {
                if _child.isEqual(node.rootNode.childNode(withName: childName, recursively: true)) {
                    return node
                }
            }
        }
        return nil
    }

    func scroll(_ velocity: CGPoint) {
        self.rootNode.position.y -= Float(velocity.y) * self.velocityScale
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
    
    @objc func shiftDomainToCenter() {
        var mx: Float = 0.0
        var my: Float = 0.0
        
        
        if self.nodes.count > 0 {
            for node in self.nodes {
                mx += node.rootNode.position.x
                my += node.rootNode.position.y
            }
            
            mx /= Float(self.nodes.count)
            my /= Float(self.nodes.count)

//            self.rootNode.position = SCNVector3Make(self.rootNode.position.x - mx,
//                                                    self.rootNode.position.y - my,
//                                                    self.rootNode.position.z)
            
            self.rootNode.position = SCNVector3Make( -mx,
                                                     self.rootNode.position.y,
                                                     self.rootNode.position.z)
        }
//        print(self.rootNode.position)
        
//        for node in self.nodes {
//            node.rootNode.position = SCNVector3Make(node.rootNode.position.x - mx,
//                                                    node.rootNode.position.y - my,
//                                                    node.rootNode.position.z)
//        }
        
    }
}











// end
