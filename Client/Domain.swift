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
    var renderTree: RenderTree = RenderTree()
    var asyncRenderTree: AsyncRenderTree = AsyncRenderTree()
    var rootKey: String = ""
    var rootNode: SCNNode = SCNNode()
    
    var requestID: String = ""
    var requestURL: String = ""
    
    let viewport: Viewport = Viewport()
    
    let scale: Float = 0.001
    let velocityScale: Float = 0.0001
    var isReady: Bool = false
    var maxZOffset: Float = 0.0
    
    init(_ requestURL: String) {
        self.requestURL = requestURL
    }
    
    func constructRenderTree(_ _data: JSON,
                     _ _requestID: String) {
        
        self.data = _data
        self.requestID = _requestID
        
        performance.measure("Get Root Key") {
            self.getRootKey()
        }

        if let renderTreeRootNodeData = self.data?[ self.rootKey ] {
            performance.measure("constructRenderTreeAsync") {
                self.asyncRenderTree.push( self.rootKey )
                while self.asyncRenderTree.hasNextNode {
                    
                    // ---- async
                    
                    let nodeKey = self.asyncRenderTree.next()
                    
                    for (_, childKey) in (self.data?[ nodeKey ]["nodeChildren"])! {
                        
                        if let childNodeData = self.data?[ childKey.stringValue ] {
                            if childNodeData.count > 0 {
                                self.asyncRenderTree.push( childKey.stringValue )
                            }else {}
                        } else {}
                    }
                    // ----
                }
            } // end perf measure
            
            asyncRenderTree._print()
            exit()
            
            self.render()
            
        } else {
            print("Error: No root node exists with key \(self.rootKey)")
        }
//        if let renderTreeRootNodeData = self.data?[ self.rootKey ] {
//            performance.measure("constructRenderTree") {
//                if let newRootNode = Node( self.rootKey, renderTreeRootNodeData, self.requestURL, 0) {
//                self.renderTree.push( newRootNode )
//                    while self.renderTree.hasNextNode {
//
//                        // ---- async
//
//                        let node = self.renderTree.next()
//
//                        for (_, childKey) in node.childrenKeys() {
//
//                            if let childNodeData = self.data?[ childKey.stringValue ] {
//                                if childNodeData.count > 0 {
//
//                                    if let childNode = Node( childKey.stringValue, childNodeData, self.requestURL, node.treeDepth + 1) {
//                                        self.renderTree.push( childNode )
//                                        node.addChild(childNode)
//                                    } else {}
//                                }else {}
//                            } else {}
//                        }
//
//                        // ----
//                    }
//                }
//            } // end perf measure
//
//            self.render()
//
//        } else {
//            print("Error: No root node exists with key \(self.rootKey)")
//        }
    }
    
    func render() {
        renderTree.draw()
        for node in renderTree.nodes {
            if node.canRender {
                self.rootNode.addChildNode(node.rootNode)
            }
        }
    }
    
    private func getRootKey() {
        for (key, _) in self.data {
            if key.hasPrefix("#document-1-") {
                self.rootKey = key
                return
            }
        }
    }
    
    func getNode(withKey ref: String) -> Node? {
        for node in self.renderTree.nodes {
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
