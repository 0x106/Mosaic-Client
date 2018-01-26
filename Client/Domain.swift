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
    var nodes: [Text] = [Text]()
    var rootNode: SCNNode = SCNNode()
    
    func setData(_ data: JSON) {
        
        self.data = data
        
        let ignoreNameTags = ["#document", "HTML", "BODY", "IFRAME"];
        let ignoreValueTags = ["Cached", "Similar"];
        
        for (_, object) in self.data {
            
            let name = object["nodeName"].stringValue
            if !ignoreNameTags.contains(name) {
                let layout = object["nodeLayout"]
                let style = object["nodeStyle"]
                let value = object["nodeValue"].stringValue
                
                if !ignoreValueTags.contains(value) {
                    
                    if layout["width"].doubleValue > 0 && layout["height"].doubleValue > 0 {
                        if name == "#text" {
                            
                            let pkey = object["pkey"].stringValue
                            let key = object["key"].stringValue
                            guard let parent = self.getObject(withKey: pkey) else {return}
                            
                            if let element = Text(withlabel:    value,
                                                  withKey:      key,
                                                  withlayout:   layout,
                                                  withStyle:    style,
                                                  withParent:   parent)
                            {
                                self.rootNode.addChildNode(element.rootNode)
                                self.nodes.append(element)
                            } else {}
                        }
                    }
                }
            }
        }
    }
    
    func getObject(withKey ref: String) -> JSON? {
        for (_, object) in self.data {
            let query = object["key"].stringValue
            if query == ref {
                return object
            }
        }
        return nil
    }
    
    func getNode(withKey ref: String) -> Text? {
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
