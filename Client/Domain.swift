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
    
    func setData(_ data: JSON) {
        
        self.data = data
        
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
                        self.rootNode.addChildNode(element.rootNode)
                        self.nodes.append(element)
                        containerGroup.leave()
                    } else {}
                }
            }
        }
        
        
//        exit()
        
        containerGroup.notify(queue: .main) {
//            DispatchQueue.main.async {
            let containerDrawWorker = DispatchQueue(label: "containerDrawWorker", qos: .userInitiated)
            containerDrawWorker.async {
                for element in self.nodes {
                    element.draw()
                }
            }
        }
        
        self.rootNode.eulerAngles = SCNVector3Make(-(.pi / 12.0), 0.0, 0.0)
        
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
}
