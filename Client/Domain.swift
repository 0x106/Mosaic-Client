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
    var nodeDict: Dictionary<String, Node> = Dictionary<String, Node>()
    var requestID: String = ""
    var requestURL: String = ""
    
    let configManager: ConfigManager = ConfigManager()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    
    var renderNodeList: Set = Set<String>()
    var renderMonitor: RenderMonitor = RenderMonitor()
    var renderTree: Dictionary<String, Any> = [:]
    var renderTreeRootNode: SCNNode = SCNNode()
    
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
                
                // will always return a Node object
                guard let node: Node = Node(data, self.requestURL, 0, self.configManager.config_data) else {
                    return
                }
                renderNode(node, key)
                
            }
        }
    }
    
    func renderNode(_ node: Node, _ key: String) {
        if node.render() {
            self.rootNode.addChildNode(node.rootNode)
            self.nodes.append(node)
            self.nodeDict[key] = node
        }
    }
    
    func getNode(withKey ref: String) -> Node? {
        
        if let node = self.nodeDict[ref] {
            if node.canRender {
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
   
            self.rootNode.position = SCNVector3Make( -mx,
                                                     self.rootNode.position.y,
                                                     self.rootNode.position.z)
        }
        
        if self.allDataSent {
            self.centerTimer.invalidate()
//            self.processRenderTree()
        }
        
    }
    
    func processRenderTree() {
        for node in self.nodes {
            if node.childrenKeys.count > 0 {
                for child_key in node.childrenKeys {
                    if let child_node = self.nodeDict[child_key] {
                        node.rootNode.addChildNode(child_node.rootNode)
                    }
                }
            }
        }
        
        if let root_key = self.renderTree["root"] as? String {
            if let root = self.nodeDict[ root_key ] {
                self.rootNode.addChildNode(root.rootNode)
            }
        }
        
    }
}
//        if let root_key = self.renderTree["root"] as? String {
//
//            var tree: [String] = [root_key]
//            var ptr = 0
//
//            while ptr < tree.count {
//
//                if let parent = self.nodeDict[ tree[ptr] ] {
//
//                    for child in parent.childrenKeys {
//
//                        tree.append(child)
//
//                    }
//
//                }
//                ptr += 1
//            }
//
//            print(tree)
//
//
//        }
        
//        print("===============================")
//        print(self.renderTree)
//
//        var tree: [String] = [String]()
//
//        if let rt_root_key = self.renderTree["root"] as? String {
//            print("Render tree root: \(rt_root_key)")
//
//            tree.append(rt_root_key)
//            var ptr = 0
//
//            if let rt_root_data = self.renderTree["shadowTree"] as? Dictionary<String, Any> {
//
//                while(ptr < tree.count) {
//
//                    var parentKey = tree[ptr]
//
//                    if let next_data = rt_root_data[parentKey] as? Dictionary<String, Any> {
//                        for (child_key, child_value) in next_data {
//                            print(child_key)
//                        }
//                    }
//                }
//            }
//        }
//
//
//        print("===============================")



//["shadowTree": {
//    "#document-bCBDceZ$" =     {
//        "HTML-PDTlgu@9" =         {
//        };
//    };
//    "#text-$Yg$R0Sr" =     {
//    };
//    "#text-(bdOM9MU" =     {
//    };
//    "#text-BviU7E$2" =     {
//    };
//    "#text-FISGlKcK" =     {
//    };
//    "#text-Z^VwNc9&" =     {
//    };
//    "#text-^3m@LPaM" =     {
//    };
//    "#text-cHnC#bsN" =     {
//    };
//    "#text-p)pWt2(N" =     {
//    };
//    "#text-x0xmQ$Ml" =     {
//    };
//    "A-52UATlYs" =     {
//        "#text-(bdOM9MU" =         {
//        };
//    };
//    "ATLAS-v5rHU*x)" =     {
//    };
//    "BODY-Oy3xhyZI" =     {
//        "#text-Z^VwNc9&" =         {
//        };
//        "#text-cHnC#bsN" =         {
//        };
//        "A-52UATlYs" =         {
//        };
//        "ATLAS-v5rHU*x)" =         {
//        };
//        "DIV-K1O4bjx$" =         {
//        };
//        "DIV-tgSt^6ks" =         {
//        };
//        "P-%M83EfCD" =         {
//        };
//        "P-BULRvR&y" =         {
//        };
//        "P-PWzZe&$b" =         {
//        };
//        "P-RfuX0TGK" =         {
//        };
//        "P-n!!V@P)y" =         {
//        };
//    };
//    "DIV-K1O4bjx$" =     {
//        "H1-rw2oZH9G" =         {
//        };
//    };
//    "DIV-tgSt^6ks" =     {
//    };
//    "H1-rw2oZH9G" =     {
//        "#text-$Yg$R0Sr" =         {
//        };
//    };
//    "HTML-PDTlgu@9" =     {
//        "BODY-Oy3xhyZI" =         {
//        };
//    };
//    "P-%M83EfCD" =     {
//        "#text-x0xmQ$Ml" =         {
//        };
//    };
//    "P-BULRvR&y" =     {
//        "#text-^3m@LPaM" =         {
//        };
//    };
//    "P-PWzZe&$b" =     {
//        "#text-p)pWt2(N" =         {
//        };
//    };
//    "P-RfuX0TGK" =     {
//        "#text-FISGlKcK" =         {
//        };
//    };
//    "P-n!!V@P)y" =     {
//        "#text-BviU7E$2" =         {
//        };
//    };
//    }, "root": #document-bCBDceZ$]
//Render tree root: #document-bCBDceZ$





















// end
