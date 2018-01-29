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
    var nodes: [Element] = [Element]()
    var rootNode: SCNNode = SCNNode()
    
    func setData(_ data: JSON) {
        
        self.data = data
        
        let ignoreNameTags = ["#document", "HTML", "BODY", "IFRAME"];
        let ignoreValueTags = ["Cached", "Similar"];
        
        print(self.data)
        
//        Async.userInitiated {
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
//                                    self.rootNode.addChildNode(element.bgNode)
                                    self.rootNode.addChildNode(element.rootNode)
                                    self.nodes.append(element)
                                } else {}
                            } else if name == "LI" {
                                
                                let pkey = object["pkey"].stringValue
                                let key = object["key"].stringValue
                                guard let parent = self.getObject(withKey: pkey) else {return}
                                
                                if let element = Generic(withKey:      key,
                                                         withlayout:   layout,
                                                         withStyle:    style,
                                                         withParent:   parent)
                                {
                                    self.rootNode.addChildNode(element.rootNode)
                                    self.nodes.append(element)
                                } else {}
                                
                            } else if name == "DIV" {
                                
                                // probably need to check that break skips to the next element in the for-loop
                                if let bgImage = self.getAttribute(style, "background-image"), bgImage != "none" {

                                    let pkey = object["pkey"].stringValue
                                    let key = object["key"].stringValue
                                    guard let parent = self.getObject(withKey: pkey) else {return}

                                    if let element = Image(withValue:   bgImage.stringValue,
                                                          withKey:      key,
                                                          withlayout:   layout,
                                                          withStyle:    style,
                                                          withParent:   parent)
                                    {
//                                        self.rootNode.addChildNode(element.rootNode)
//                                        self.nodes.append(element)
                                    } else {}
                                }
                                // probably need to check that break skips to the next element in the for-loop
                                if let bgImage = self.getAttribute(style, "background-image"), bgImage != "none" {
                                    
                                    let pkey = object["pkey"].stringValue
                                    let key = object["key"].stringValue
                                    guard let parent = self.getObject(withKey: pkey) else {return}
                                    
                                    if let element = Image(withValue:   bgImage.stringValue,
                                                           withKey:      key,
                                                           withlayout:   layout,
                                                           withStyle:    style,
                                                           withParent:   parent)
                                    {
                                        //                                        self.rootNode.addChildNode(element.rootNode)
                                        //                                        self.nodes.append(element)
                                    } else {}
                                }
                            }
                        }
                    }
                }
            }
//        }
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
    
    func getNode(withKey ref: String) -> Element? {
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
    
    func getAttribute(_ object: JSON, _ query: String) -> JSON? {
        
        for (key, value) in object {
            if query == value["name"].stringValue {
                return value["value"]
            }
        }
        
        return nil
    }
}
