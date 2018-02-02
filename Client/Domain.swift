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
import Async

class Domain {
    
    var data: JSON!
    var nodes: [Container] = [Container]()
    var rootNode: SCNNode = SCNNode()
    var requestID: String = ""
    let viewport: Viewport = Viewport()
    let scale: Float = 0.001
    
    func setData(_ data: JSON, _ requestID: String) {
        
        self.data = data
        self.requestID = requestID
        
        let ignoreNameTags = ["#document", "HTML", "IFRAME"];
        let ignoreValueTags = ["Cached", "Similar"];
        
//        print(self.data)
        
        let containerGroup = DispatchGroup()
        
        for (key, object) in self.data {
                
            let name = object["nodeName"].stringValue
            let layout = object["nodeLayout"]
            let style = object["nodeStyle"]
            let value = object["nodeValue"].stringValue
            
            if      !ignoreNameTags.contains(name)
                &&  !ignoreValueTags.contains(value)
                &&  layout["width"].doubleValue > 0 && layout["height"].doubleValue > 0
                &&  (name == "#text" || name == "DIV" || name == "TD" || name == "TABLE" || name == "NAV" || name == "LI" || name == "BODY") {

                let pkey = object["pkey"].stringValue
                let parent = self.data[pkey]
            
                let domainWorker = DispatchQueue(label: "domainWorker", qos: .userInitiated)
                domainWorker.async {
    
                    containerGroup.enter()
                    if let element = Container(withName:     name,
                                               withlabel:    value,
                                               withKey:      key,
                                               withlayout:   layout,
                                               withStyle:    style,
                                               withParent:   parent)
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
        
        // self.rootNode.eulerAngles = SCNVector3Make(-(.pi / 12.0), 0.0, 0.0)
    }
    
    func drawNodes() {
        if DEBUG {
            for element in self.nodes {
                element.draw()
                self.rootNode.addChildNode(element.rootNode)
            }
            self.writeSceneToFile()
        } else {
            let drawingGroup = DispatchGroup()
            let containerDrawWorker = DispatchQueue(label: "containerDrawWorker", qos: .userInitiated)
            containerDrawWorker.async {
                for element in self.nodes {
                    if self.viewport.contains(element) { // if element is in viewport
                        drawingGroup.enter()
                        element.draw()
                        self.rootNode.addChildNode(element.rootNode)
                        drawingGroup.leave()
                    }
                }
            }
            
            drawingGroup.notify(queue: .main) {
                self.writeSceneToFile()
            }
        }
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
    
    func onPlane(_ planeNode: SCNNode) {
        self.rootNode.position = planeNode.position
    }
    
    private func writeSceneToFile() {
        if DEBUG {
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let file = URL(fileURLWithPath: documents + "/\(self.requestID).scn")
            
            let scene = SCNScene()
            scene.rootNode.addChildNode(self.rootNode)
            scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
            print("Scene written to: \(file)")
        }
    }
    
    func scroll(_ velocity: CGPoint) {
        self.rootNode.position.y += Float(velocity.y) * self.scale
        update()
    }
    
    func update() {
        let updateWorker = DispatchQueue(label: "updateWorker", qos: .userInitiated)
        updateWorker.async {
            
            // for each node
            for element in self.nodes {
                
                let position = SCNVector3Make(element.rootNode.position.x + self.rootNode.position.x,
                                              element.rootNode.position.y + self.rootNode.position.y,
                                              element.rootNode.position.z + self.rootNode.position.z)
                
                // if the node is in view
                if self.viewport.contains(position) {
                 
                    // ensure that it has been drawn
                    if !element.isRendered {
                        element.draw()
                    }
                
                    // ensure that any node in the viewport is visible
//                    element.rootNode.isHidden = false
                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(1.0)
                } else {
                    // if a node is not in the viewport but has previously been rendered then hide it
//                    element.rootNode.isHidden = true
                    element.rootNode.geometry?.firstMaterial?.transparency = CGFloat(0.2)
                }
            }
            
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
        
        print("Viewport created with dimensions: \(x[0]), \(x[1]), \(y[0]), \(y[1]), \(z[0]), \(z[1])")
        
    }
    
    func contains(_ element: Container) -> Bool {
        if     (element.rootNode.position.x >= self.x[0] && element.rootNode.position.x <= self.x[1])
            && (element.rootNode.position.y >= self.y[0] && element.rootNode.position.y <= self.y[1])
            && (element.rootNode.position.z >= self.z[0] && element.rootNode.position.z <= self.z[1]) {
            
            return true
        }
        
        return false
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
