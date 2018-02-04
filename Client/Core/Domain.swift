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
    var nodes: [Container] = [Container]()
    var rootNode: SCNNode = SCNNode()
    var requestID: String = ""
    var requestURL: String = ""
    let viewport: Viewport = Viewport()
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    var isReady: Bool = false
    var otherNodes: [SCNNode] = [SCNNode]()
    var ZOffsets: [Float] = [Float]()
    var maxZOffset: Float = 0.0
    
    init(_ requestURL: String) {
        self.requestURL = requestURL
    }
    
    func setData(_ data: JSON, _ requestID: String) {
        
        self.data = data
        self.requestID = requestID
        
        let ignoreNameTags = ["#document", "HTML", "IFRAME"];
        let ignoreValueTags = ["Cached", "Similar"];
        
        let containerGroup = DispatchGroup()
        
        self.getZOffsets()
        
        for (key, object) in self.data {
                
            let name = object["nodeName"].stringValue
            let layout = object["nodeLayout"]
            let style = object["nodeStyle"]
            let value = object["nodeValue"].stringValue
            
            if      !ignoreNameTags.contains(name)
                &&  !ignoreValueTags.contains(value)
                &&  layout["width"].doubleValue > 0 && layout["height"].doubleValue > 0
                &&  (name == "#text" || name == "TD" || name == "TABLE" || name == "NAV" || name == "LI" || name == "BODY" || name == "IMG") {
//                &&  (name == "#text" || name == "DIV" || name == "TD" || name == "TABLE" || name == "NAV" || name == "LI" || name == "BODY" || name == "IMG") {

                let pkey = object["pkey"].stringValue
                let parent = self.data[pkey]
                
                let attrs = object["attr"]
            
                let domainWorker = DispatchQueue(label: "domainWorker", qos: .userInitiated)
                domainWorker.async {
    
                    containerGroup.enter()
                    if let element = Container(withName:     name,
                                               withlabel:    value,
                                               withKey:      key,
                                               withlayout:   layout,
                                               withStyle:    style,
                                               withParent:   parent,
                                               withAttrs:    attrs,
                                               withRequestURL: self.requestURL,
                                               withMaxZ:     self.maxZOffset)
                    {
                        self.nodes.append(element)
                        containerGroup.leave()
                    } else {}
                }
            }
        }
    
        containerGroup.notify(queue: .main) {
            self.drawNodes()
        }
    }
    
    func drawNodes() {
        if DEBUG {
            for element in self.nodes {
                element.draw()
                self.rootNode.addChildNode(element.rootNode)
            }
            
            self.moveItemsToCentre()
            
            self.isReady = true
            self.writeSceneToFile()
        } else {
            let drawingGroup = DispatchGroup()
            let containerDrawWorker = DispatchQueue(label: "containerDrawWorker", qos: .userInitiated)
            containerDrawWorker.async {
                for element in self.nodes {
                    if self.viewport.contains(element.rootNode.worldPosition) { // if element is in viewport
                        drawingGroup.enter()
                        element.draw()
                        self.rootNode.addChildNode(element.rootNode)
                        drawingGroup.leave()
                    }
                }
            }
            
            drawingGroup.notify(queue: .main) {
                self.moveItemsToCentre()
                self.isReady = true
                self.writeSceneToFile()
            }
        }
    }
    
    func moveItemsToCentre() {
        var domainCentre = centre()
        for element in self.nodes {
            element.rootNode.position.x -= Float(domainCentre.x)
            element.rootNode.position.y -= Float(domainCentre.y)
        }
        domainCentre = centre()
    }
    
    // spending a lot of time in this function.
    func getObject(withKey ref: String) -> JSON? {
        for (_, object) in self.data {
            let query = object["key"].stringValue
            if query == ref {
                return object
            }
        }
        return nil
    }
    
    func getNode(withKey ref: String) -> Container? {
        for node in self.nodes {
            if node.nodeKey == ref {
                return node
            }
        }
        return nil
    }
    
    private func writeSceneToFile() {
        if DEBUG {
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let file = URL(fileURLWithPath: documents + "/\(self.requestID).scn")
            
            let scene = SCNScene()
            scene.rootNode.addChildNode(self.rootNode)
            scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
            print("Domain scene written to: \(file)")
        }
    }
    
    func scroll(_ velocity: CGPoint) {
        self.rootNode.position.y -= Float(velocity.y) * self.velocityScale
        update()
    }
    
    func update() {
        let updateWorker = DispatchQueue(label: "updateWorker", qos: .userInitiated)
        updateWorker.async {
            for element in self.nodes {
                if self.viewport.contains(element.rootNode.worldPosition) {
                 
                    if !element.isRendered {
                        element.draw()
                    }
                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(1.0)
                } else {
//                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(0.2)
                }
            }
            
        }
    }
    
    func explosion() {
        
        let domainCentre = centre()
        let animationScale: Float = 0.01
        
        for element in self.nodes {
            
            let node = element.rootNode
            
            let point = pointOnCircle(0.4, node.position.x, Float(domainCentre.x), node.position.y, Float(domainCentre.y))
            
            let motion = SCNVector3Make(Float(point.x) * animationScale, Float(point.y) * animationScale, -1.0)
            let action = SCNAction.move(to: motion, duration: 1.0)
            
            // node.runAction(SCNAction.repeatForever(action))
            node.runAction(action)
            
        }
    }
    
    func centre() -> CGPoint {
        var point = CGPoint(x: 0.0, y: 0.0)
        
        var x_count = 0, y_count = 0
        for element in self.nodes {
            point.x += CGFloat(element.rootNode.position.x)
            x_count += 1
            
            if element.rootNode.position.y > Float(-1.0) && element.rootNode.position.y < Float(1.0) {
                point.y += CGFloat(element.rootNode.position.y)
                y_count += 1
            }
        }
        
        point.x /= CGFloat(x_count)
        point.y /= CGFloat(y_count)
        return point
    }
    
    private func getZOffsets() {
        for (key, _) in self.data {
            let index = Float(indexFromKey(key))
            if index > self.maxZOffset {
                self.maxZOffset = index
            }
            self.ZOffsets.append( index )
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
