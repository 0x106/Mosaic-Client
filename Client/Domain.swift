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
            
            if let newRootNode = Node( self.rootKey, renderTreeRootNodeData, self.requestURL, 0) {
            self.renderTree.push( newRootNode )
                while self.renderTree.hasNextNode {
                    
                    let node = self.renderTree.next()
                    for (_, childKey) in node.childrenKeys() {
                            
                        if let childNodeData = self.data?[ childKey.stringValue ] {
                            if childNodeData.count > 0 {
        
                                if let childNode = Node( childKey.stringValue, childNodeData, self.requestURL, node.treeDepth + 1) {
                                    self.renderTree.push( childNode )
                                    node.addChild(childNode)
                                } else {}
                            }else {}
                        } else {}
                    }
                }
            }
            
            self.render()

        } else {
            print("Error: No root node exists with key \(self.rootKey)")
        }
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
    
//
//
//    func setData(_ data: JSON, _ requestID: String) {
//
//        self.data = data
//        self.requestID = requestID
//
//        print (self.data)
//
//        let ignoreNameTags = ["#document", "HTML", "IFRAME"];
//        let ignoreValueTags = ["Cached", "Similar"];
//
//        let containerGroup = DispatchGroup()
//
//        self.getZOffsets()
//
//        for (key, object) in self.data {
//
//            let name = object["nodeName"].stringValue
//            let layout = object["nodeLayout"]
//            let style = object["nodeStyle"]
//            let value = object["nodeValue"].stringValue
//
//            if      !ignoreNameTags.contains(name)
//                &&  !ignoreValueTags.contains(value)
//                &&  layout["width"].doubleValue > 0 && layout["height"].doubleValue > 0
//                &&  (name == "#text" || name == "TD" || name == "TABLE" || name == "NAV" || name == "LI" || name == "BODY" || name == "IMG" || name == "INPUT" || name == "DIV") {
////                &&  (name == "#text" || name == "DIV" || name == "TD" || name == "TABLE" || name == "NAV" || name == "LI" || name == "BODY" || name == "IMG") {
//                let pkey = object["pkey"].stringValue
//                let parent = self.data[pkey]
//
//                let attrs = object["attr"]
//
//                let display = getAttribute(style, "display")?.stringValue
////                print(display)
//
////                let domainWorker = DispatchQueue(label: "domainWorker", qos: .userInitiated)
////                domainWorker.async {
//
////                    containerGroup.enter()
//                    if let element = Container(withName:     name,
//                                               withlabel:    value,
//                                               withKey:      key,
//                                               withlayout:   layout,
//                                               withStyle:    style,
//                                               withParent:   parent,
//                                               withAttrs:    attrs,
//                                               withRequestURL: self.requestURL,
//                                               withMaxZ:     self.maxZOffset)
//                    {
////                        self.nodes.append(element)
////                        element.draw()
////                        containerGroup.leave()
//                    } else {}
////                }
//            }
//        }
//
////        containerGroup.notify(queue: .main) {
//            self.drawNodes()
////        }
//    }
//
//    func drawNodes() {
//        if DEBUG {
////            for element in self.nodes {
////                element.draw()
////                self.rootNode.addChildNode(element.rootNode)
////            }
//
////            self.moveItemsToCentre()
//
//            self.isReady = true
////            self.writeSceneToFile()
//        } else {
//            let drawingGroup = DispatchGroup()
//            let containerDrawWorker = DispatchQueue(label: "containerDrawWorker", qos: .userInitiated)
//            containerDrawWorker.async {
////                for element in self.nodes {
//////                    if self.viewport.contains(element.rootNode.worldPosition) { // if element is in viewport
////                        drawingGroup.enter()
////                        element.draw()
////                        self.rootNode.addChildNode(element.rootNode)
////                        drawingGroup.leave()
//////                    }
////                }
//            }
//
//            drawingGroup.notify(queue: .main) {
//                self.moveItemsToCentre()
//                self.isReady = true
////                self.writeSceneToFile()
//            }
//        }
//    }
//
//    func moveItemsToCentre() {
//        var domainCentre = centre()
////        for element in self.nodes {
////            element.rootNode.position.x -= Float(domainCentre.x)
////            element.rootNode.position.y -= Float(domainCentre.y)
////        }
//        domainCentre = centre()
//    }
//
//
//    func centre() -> CGPoint {
//        var point = CGPoint(x: 0.0, y: 0.0)
//
//        var x_count = 0, y_count = 0
////        for element in self.nodes {
////            point.x += CGFloat(element.rootNode.position.x)
////            x_count += 1
////
////            if element.rootNode.position.y > Float(-1.0) && element.rootNode.position.y < Float(1.0) {
////                point.y += CGFloat(element.rootNode.position.y)
////                y_count += 1
////            }
////        }
//
//        point.x /= CGFloat(x_count)
//        point.y /= CGFloat(y_count)
//        return point
//    }
//
//    private func getZOffsets() {
//        for (key, _) in self.data {
//            let index = Float(indexFromKey(key))
//            if index > self.maxZOffset {
//                self.maxZOffset = index
//            }
////            self.ZOffsets.append( index )
//        }
//    }
//}


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
