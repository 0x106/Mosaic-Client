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
        
        if DEBUG {
            containerGroup.notify(queue: .main) {
                for element in self.nodes {
                    element.draw()
                    self.rootNode.addChildNode(element.rootNode)
                }
                self.writeSceneToFile()
            }
        } else {
            let drawingGroup = DispatchGroup()
            containerGroup.notify(queue: .main) {
                let containerDrawWorker = DispatchQueue(label: "containerDrawWorker", qos: .userInitiated)
                containerDrawWorker.async {
                    for element in self.nodes {
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
        
//        self.rootNode.eulerAngles = SCNVector3Make(-(.pi / 12.0), 0.0, 0.0)
        
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
}
